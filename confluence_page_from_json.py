#!/reg/g/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python

import json
import os
import sys
from typing import List, Optional, Tuple

import atlassian
import jinja2
import requests

CONFLUENCE_URL = "https://confluence.slac.stanford.edu"
CONFLUENCE_TOKEN = os.environ.get(
    "CONFLUENCE_TOKEN",
    os.environ["TYPHOS_HELP_TOKEN"]
)
CONFLUENCE_LABELS = []

# A directory in which we store the last-published state of the Confluence
# document - as we can no longer use HTML in our pages.
CONFLUENCE_STATE_PATH = os.environ["CONFLUENCE_STATE_PATH"]


class NamedTemplate:
    """
    A jinja template that contains a title and some additional information.

    There may be multiple titles provided; the first valid one will be used.
    Labels will be applied to the generated page by name.

    Parameters
    ----------
    fn : str
        The template filename.
    """
    filename: str
    titles: List[jinja2.Template]
    template: jinja2.Template
    labels: List[str]

    def __init__(self, fn: str):
        with open(fn, "rt") as fp:
            contents = fp.read().splitlines()
        info, contents = self._split_title_and_contents(contents)
        self.filename = fn
        self.labels = list(sorted(set(info["labels"]) | set(CONFLUENCE_LABELS)))
        self.titles = [jinja2.Template(title) for title in info["title_lines"]]
        self.template = jinja2.Template(contents)

        if not self.titles:
            raise ValueError(f"Template invalid: {fn} has no filename lines")

    @staticmethod
    def _split_title_and_contents(contents) -> Tuple[dict, str]:
        """Parse the template, grabbing header information and contents."""
        info = {
            "title_lines": [],
            "labels": [],
        }
        for idx, line in enumerate(contents):
            if line.startswith("# "):
                line = line.strip("# ")
                directive, data = (item.strip() for item in line.split(":", 1))
                if directive == "title":
                    info["title_lines"].append(data)
                elif directive == "label":
                    info["labels"].append(data)
                else:
                    raise ValueError(f"Unknown directive: {directive} ({data})")
            else:
                contents = "\n".join(contents[idx:])
                break

        return info, contents

    def __repr__(self):
        return f"<NamedTemplate {self.filename}>"

    def render(self, **kwargs) -> Tuple[List[str], str]:
        """
        Render the template with the given kwargs.

        Returns
        -------
        titles : list of str
            List of potential titles, to be checked on confluence.

        rendered : str
            The rendered page.
        """
        return (
            [title.render(**kwargs) for title in self.titles],
            self.template.render(**kwargs)
        )


def create_client(
    url: str = CONFLUENCE_URL, token: str = CONFLUENCE_TOKEN
) -> atlassian.Confluence:
    """Create the Confluence client.

    Parameters
    ----------
    url : str
        The confluence URL.

    token : str
        The token with read/write permissions.
    """
    s = requests.Session()
    s.headers["Authorization"] = f"Bearer {token}"
    return atlassian.Confluence(url, session=s)


def get_state_filename(page_id: int) -> str:
    return os.path.join(CONFLUENCE_STATE_PATH, f"{page_id}.json")


def should_update(page_id: int, json_source: str) -> bool:
    """Check whether ``page_id`` should be updated."""
    try:
        with open(get_state_filename(page_id)) as fp:
            last_source = fp.read()
    except FileNotFoundError:
        print("Last source page not found!")
        return True

    # Compare an embedded version of the raw JSON, as confluence can
    # rewrite our html on us
    return last_source.strip() != json_source.strip()


def write_state(page_id: int, json_source: str) -> None:
    """Check whether ``page_id`` should be updated."""
    with open(get_state_filename(page_id), "wt") as fp:
        print(json_source, file=fp)


def update_page(
    filename: str,
    space_and_page: str,
    keys: Optional[List[str]] = None,
    force: bool = False,
    marker: str = "**CONFLUENCE_FROM_JSON**"
):
    with open(filename) as fp:
        raw_json = fp.read()

    rows = json.loads(raw_json)

    space, title = space_and_page.split("/", 1)
    client = create_client()
    existing_page: Optional[dict] = client.get_page_by_title(
        title=title,
        space=space,
        expand="body.storage",
    )

    page_id = existing_page["id"]
    if not existing_page:
        print("Page not found?")
        return

    if not should_update(page_id, raw_json):
        print("Page already up-to-date; exiting")
        return

    print("Page to be updated.")
    if keys:
        columns = keys
    else:
        all_items = sum(
            (
                list((key, value) for (key, value) in row.items() if str(value))
                for row in rows
            ),
            [],
        )
        columns = list(dict(all_items))

    new_title, new_source = NamedTemplate("json_page.template").render(
        raw_json=raw_json,
        marker=marker,
        columns=columns,
        rows=rows,
        title=title,
    )
    page_info = client.update_page(
        page_id=page_id,
        title=new_title[0],
        body=new_source,
        minor_edit=True,
        version_comment="confluence_page_from_json update",
    )

    # Keep track for next time
    write_state(page_id, raw_json)
    return page_info


def main():
    if not os.path.isdir(CONFLUENCE_STATE_PATH):
        raise RuntimeError("CONFLUENCE_STATE_PATH not set appropriately")

    filename, space_and_page, *keys = sys.argv[1:]
    update_page(filename, space_and_page, keys)


if __name__ == "__main__":
    main()
