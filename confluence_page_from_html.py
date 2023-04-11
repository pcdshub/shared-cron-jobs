#!/reg/g/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python

import hashlib
import pathlib
import sys

from confluence_helpers import NamedTemplate, create_client

MODULE_PATH = pathlib.Path(__file__).expanduser().resolve().parent


def get_file_sha256(filename: str) -> str:
    """Hash a file's contents with the SHA-256 algorithm."""
    with open(filename, "rb") as fp:
        return hashlib.sha256(fp.read()).hexdigest()


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
    existing_page = client.get_page_by_title(
        title=title,
        space=space,
        expand="body.storage",
    )

    if existing_page is None:
        print("Unable to find existing page (empty response?)")
        return

    page_id = existing_page.get("id", None)
    if not existing_page or page_id is None:
        print("Unable to find existing page", existing_page)
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
        existing_hash = "\n".join(source_lines[:source_lines.index(marker)])
        if existing_hash.strip() == html_hash:
            print("Hash unchanged")
            return

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
    return page_info


if __name__ == "__main__":
    filename, space_and_page = sys.argv[1:]
    update_page(filename, space_and_page)
