#!/reg/g/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python

import hashlib
import os
import pathlib
import sys
from typing import Optional

from confluence_helpers import NamedTemplate, create_client

MODULE_PATH = pathlib.Path(__file__).expanduser().resolve().parent
# A directory in which we store the last-published state of the Confluence
# document - as we can no longer use HTML in our pages.
CONFLUENCE_STATE_PATH = os.environ["CONFLUENCE_STATE_PATH"]


def get_file_sha256(filename: str) -> str:
    """Hash a file's contents with the SHA-256 algorithm."""
    with open(filename, "rb") as fp:
        return hashlib.sha256(fp.read()).hexdigest()


def get_state_filename(page_id: int) -> str:
    return os.path.join(CONFLUENCE_STATE_PATH, f"{page_id}.html")


def should_update(page_id: int, html_source: str) -> bool:
    """Check whether ``page_id`` should be updated."""
    try:
        with open(get_state_filename(page_id)) as fp:
            last_source = fp.read()
    except FileNotFoundError:
        print("Last source page not found!")
        return True

    # Compare an embedded version of the raw JSON, as confluence can
    # rewrite our html on us
    return last_source.strip() != html_source.strip()


def write_state(page_id: int, html_source: str) -> None:
    """Check whether ``page_id`` should be updated."""
    with open(get_state_filename(page_id), "wt") as fp:
        print(html_source, file=fp)


def update_page(
    filename: str,
    space_and_page: str,
    force: bool = False,
    marker: str = "**CONFLUENCE_FROM_HTML**"
):
    html_hash = get_file_sha256(filename)
    with open(filename) as fp:
        raw_html = fp.read()

    space, title = space_and_page.split("/", 1)
    client = create_client()
    existing_page: Optional[dict] = client.get_page_by_title(
        title=title,
        space=space,
        expand="body.storage",
    )

    if existing_page is None or not existing_page:
        print("Unable to find existing page (empty response?)")
        return

    page_id = existing_page.get("id", None)
    if page_id is None:
        print("Unable to find existing page", existing_page)
        return

    if not should_update(page_id, raw_html):
        print("Page already up-to-date; exiting")
        return

    print("Page to be updated.")

    tpl = NamedTemplate(MODULE_PATH / "html_page.template")
    new_title, new_source = tpl.render(
        html_hash=html_hash,
        html_source=raw_html,
        marker=marker,
        title=title,
    )
    page_info = client.update_page(
        page_id=page_id,
        title=new_title[0],
        body=new_source,
        minor_edit=True,
        version_comment="confluence_page_from_html update",
    )
    write_state(page_id, raw_html)
    return page_info


def main():
    if not os.path.isdir(CONFLUENCE_STATE_PATH):
        raise RuntimeError("CONFLUENCE_STATE_PATH not set appropriately")

    filename, space_and_page = sys.argv[1:]
    update_page(filename, space_and_page)


if __name__ == "__main__":
    main()
