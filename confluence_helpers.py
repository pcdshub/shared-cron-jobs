#!/cds/group/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python
from __future__ import annotations

import os
import pathlib
from typing import List, Tuple, Union

import atlassian
import jinja2
import requests

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
    fn : str or pathlib.Path
        The template filename.
    """
    filename: str
    titles: List[jinja2.Template]
    template: jinja2.Template
    labels: List[str]

    def __init__(self, fn: Union[pathlib.Path, str]):
        filename = pathlib.Path(fn).expanduser().resolve()
        with open(filename, "rt") as fp:
            contents = fp.read().splitlines()
        info, contents = self._split_title_and_contents(contents)
        self.filename = str(filename)
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
