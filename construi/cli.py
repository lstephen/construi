from .config import parse
from .target import Target
from .__version__ import __version__

from argparse import ArgumentParser

import logging
import os
import sys


def main():
    setup_logging()

    parser = ArgumentParser(prog='construi', description='Run construi')

    parser.add_argument('target', metavar='TARGET', nargs='?')
    parser.add_argument('--basedir', metavar='DIR', default=os.getcwd())
    parser.add_argument('--version', action='version', version=__version__)
    parser.add_argument('-T', '--list-targets', action='store_true')

    args = parser.parse_args()

    config = parse(args.basedir, 'construi.yml')

    if args.list_targets:
        list_targets(config)
        sys.exit(0)

    target = args.target or config.default

    Target(config.for_target(target)).run()


def setup_logging():
    root_logger = logging.getLogger()
    root_logger.addHandler(logging.StreamHandler(sys.stdout))
    root_logger.setLevel(logging.INFO)

    logging.getLogger("requests").propagate = False


def list_targets(config):
    targets = config.targets.keys()

    targets.sort()

    for target in targets:
        print(target)
