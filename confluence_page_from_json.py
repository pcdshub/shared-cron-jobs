#!/reg/g/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python

import os
import sys
import json
import jinja2
import atlassian
import requests

from typing import List, Optional, Tuple


CONFLUENCE_URL = "https://confluence.slac.stanford.edu"
CONFLUENCE_TOKEN = os.environ.get(
    "CONFLUENCE_TOKEN",
    os.environ["TYPHOS_HELP_TOKEN"]
)
CONFLUENCE_LABELS = []


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
        return

    # Compare an embedded version of the raw JSON, as confluence can
    # rewrite our html on us
    existing_source = (
        existing_page["body"]["storage"]["value"]
        if existing_page else ""
    )
    source_lines = existing_source.splitlines()
    if not force and source_lines.count(marker) == 2:
        source_lines = source_lines[source_lines.index(marker) + 1:]
        existing_json = "\n".join(source_lines[:source_lines.index(marker)])
        if existing_json.strip() == raw_json.strip():
            return

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
    return page_info


if __name__ == "__main__":
    filename, space_and_page, *keys = sys.argv[1:]
    update_page(filename, space_and_page, keys)
