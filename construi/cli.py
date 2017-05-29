from .config import parse, NoSuchTargetException
from .target import RunContext
from .target import Target
from .__version__ import __version__

from argparse import ArgumentParser

from compose.errors import OperationFailedError

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

    targets = args.targets or (config.default, )

    verify_targets(config, targets)

    for target in targets:
        try:
            Target(config.for_target(target)).invoke(
                RunContext(config, args.dry_run))
        except OperationFailedError, e:
            console.error("\nUnexpected Error: {}\n".format(e.msg))
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

    parser.add_argument('targets', metavar='TARGETS', nargs='+')

    return parser.parse_args()


def list_targets(config):
    targets = config.targets.keys()

    targets.sort()

    for target in targets:
        print(target)


def verify_targets(config, targets):
    wrong_targets = set(targets) - set(config.targets.keys())

    if wrong_targets:
        console.error("\nNo such targets: {}\n".format(",".join(
            wrong_targets)))
        sys.exit(1)
