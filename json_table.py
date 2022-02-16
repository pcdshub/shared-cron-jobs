#!/cds/group/pcds/pyps/conda/py39/envs/pcds-5.2.1/bin/python

import json
import sys

import prettytable


def main(data, sort_key, columns=None):
    table = prettytable.PrettyTable()
    table.field_names = columns
    for ioc in sorted(data, key=lambda ioc: ioc.get(sort_key, '?')):
        table.add_row([str(ioc.get(key, '?')) for key in table.field_names])

    print(table)


if __name__ == "__main__":
    json = json.loads(sys.stdin.read())
    main(json, sort_key=sys.argv[1], columns=sys.argv[1:])
