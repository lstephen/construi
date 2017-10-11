from .config import parse, NoSuchTargetException
from .target import BuildFailedException, RunContext, Target
from .__version__ import __version__

from argparse import ArgumentParser

from compose.errors import OperationFailedError

import construi.console as console

import logging
import os
import sys
import traceback

try:
    from shlex import quote
except ImportError:
    from pipes import quote


def main():
    setup_logging()

    args = parse_args()

    config = parse(args.basedir, 'construi.yml')

    if args.list_targets:
        list_targets(config)
        sys.exit(0)

    target = args.target or config.default

    os.environ['CONSTRUI_ARGS'] = ' '.join(
        [quote(a) for a in args.construi_args])

    try:
        Target(config.for_target(target)).invoke(
            RunContext(config, args.dry_run))
    except BuildFailedException:
        console.error("\nBuild Failed.\n")
        sys.exit(1)
    except NoSuchTargetException as e:
        console.error("\nNo such target: {}\n".format(e.target))
        sys.exit(1)
    except OperationFailedError as e:
        console.error("\nUnexpected Error: {}\n".format(e.msg))
        traceback.print_exc()
        sys.exit(1)
    except KeyboardInterrupt:
        console.warn("\nBuild Interrupted.")
        sys.exit(1)

    console.info("\nBuild Succeeded.\n")


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
    parser.add_argument('construi_args', metavar='CONSTRUI_ARGS', nargs='*')

    return parser.parse_args()


def list_targets(config):
    targets = config.targets.keys()

    targets.sort()

    for target in targets:
        print(target)
