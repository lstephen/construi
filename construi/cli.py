from .config import parse
from .target import RunContext
from .target import Target
from .__version__ import __version__

from argparse import ArgumentParser

import construi.console as console

import logging
import os
import sys
import traceback


def main():
    setup_logging()

    args = parse_args()

    config = parse(args.basedir, 'construi.yml')

    if args.list_targets:
        list_targets(config)
        sys.exit(0)

    target = args.target or config.default
    try:
        Target(config.for_target(target)).invoke(RunContext(config, args.dry_run))
    except Exception, e:
        console.error("\nUnexpected Error.\n")
        traceback.print_exc()
        sys.exit(1)


def setup_logging():
    root_logger = logging.getLogger()
    root_logger.addHandler(logging.StreamHandler(sys.stdout))
    root_logger.setLevel(logging.INFO)

    logging.getLogger("requests").propagate = False


def parse_args():
    parser = ArgumentParser(prog='construi', description='Run construi')

    parser.add_argument('--basedir', metavar='DIR', default=os.getcwd())
    parser.add_argument('-n', '--dry-run', action='store_true')
    parser.add_argument('-T', '--list-targets', action='store_true')
    parser.add_argument(
        '-v', '--version', action='version', version=__version__)

    parser.add_argument('target', metavar='TARGET', nargs='?')

    return parser.parse_args()


def list_targets(config):
    targets = config.targets.keys()

    targets.sort()

    for target in targets:
        print(target)
