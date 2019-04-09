#!/usr/bin/env python3

"""Search the web with surfraw. `sudo apt install surfraw surfraw-extras xclip`"""

import os
import argparse
from subprocess import run, PIPE


def check_engine(default, ENV_KEY="SRENGINE"):
    return os.environ.get(ENV_KEY, default)


def get_clipboard():
    return run(
        ["xclip", "-sel", "c", "-o"],
        stdout=PIPE,
        stderr=PIPE,
        universal_newlines=True,
    ).stdout.rstrip("\n")


def search(engine, query):
    cmd = ["surfraw", engine, *query]
    run(cmd)


def main():
    parser = argparse.ArgumentParser("Search the web.")
    parser.add_argument(
        '--engine', '-e',
        default=check_engine('google'),
        help="The search engine to use. You can also set with `$SRENGINE` env variable."
    )
    parser.add_argument('query', nargs="*", help="What to search for, if none then read from the clipboard.")
    args = parser.parse_args()

    if not args.query:
        args.query = [get_clipboard()]

    search(args.engine, args.query)


if __name__ == "__main__":
    main()
