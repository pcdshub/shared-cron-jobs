#!/usr/bin/env python3

import json
import pathlib
import string
import urllib.request

ecs_dashboards = pathlib.Path(
    "/cds/group/psdm/web/pswww_01_02/html/swdoc/ecs_dashboards"
)

url_format = (
    "http://ctl-logsrv01.pcdsn:3000/ctl/grafana/render/d/"
    "{dashboard}"
    "?"
    "orgId=1&"
    "width={width}&"
    "height={height}&"
    "kiosk"
)

index_link = string.Template(
    """
    <li>
      <a href="${html_filename}">${title}</a>
    </li>
    """
)
index_html = string.Template(
    """\
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset=UTF-8>
    <title>ECS Grafana Dashboard Snapshots</title>
  </head>
  <body>
    <h1>Dashboards</h1>
    The following dashboard snapshots are available:
    <ul>
      ${items}
    </ul>
    These dashboards are updated periodically.  Images will refresh
    automatically when available.
  </body>
</html>
    """
)

dashboard_html = string.Template(
    """\
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset=UTF-8>
    <title>ECS Grafana Dashboard Snapshots - ${title}</title>
    <script>
      window.onload = function() {
        var image = document.getElementById("img");

        function updateImages() {
          // console.debug("Updating images...");
          for (const image of document.body.getElementsByTagName("img")) {
            image.src = image.src.split("?")[0] + "?" + new Date().getTime();
          }
        }
        setInterval(updateImages, 30000);
        updateImages();
      }
    </script>
    <style>
      body {
        background: #111217;
        color: white;
      }
      img {
          width: 100%;
      }
    </style>
  </head>
  <body>
    <h1>${title}</h1>
    <img src="${filename}">
  </body>
</html>
""")

dashboard_info = json.load(open("dashboards.json"))

dashboards = {}

for info in dashboard_info:
    try:
        dashboard = info["dashboard"]
    except KeyError:
        continue

    try:
        dashboard_uid = dashboard.split("/")[0]
    except IndexError:
        dashboard_uid = dashboard

    width = info.get("width", 1920)
    height = info.get("height", 1080)
    filename = info.get("filename", f"{dashboard_uid}.png").lstrip("/")
    target_path = ecs_dashboards / filename
    title = info.get("title", target_path.stem)
    url = url_format.format(dashboard=dashboard, width=width, height=height)
    try:
        with urllib.request.urlopen(url) as response:
            data = response.read()
    except Exception as ex:
        print(f"Failed to get dashboard {url}: {ex.__class__.__name__} {ex}")
        continue

    try:
        with open(target_path, "wb") as fp:
            fp.write(data)
    except Exception as ex:
        print(f"Failed to write to {target_path}: {ex.__class__.__name__} {ex}")
        continue

    dashboards[title] = target_path.name


for title, filename in dashboards.items():
    html_filename = filename.split(".")[0] + ".html"
    with open(ecs_dashboards / html_filename, "wt") as fp:
        print(dashboard_html.substitute(title=title, filename=filename), file=fp)


items = "\n".join(
    index_link.substitute(title=title, html_filename=filename.split(".")[0] + ".html")
    for title, filename in dashboards.items()
)

with open(ecs_dashboards / "index.html", "wt") as fp:
    print(index_html.substitute(items=items), file=fp)
