import logging
import os
import sys
from argparse import ArgumentParser, Namespace

import construi.console as console

from .__version__ import __version__
from .config import Config, parse
from .errors import on_exception
from .target import RunContext, Target

try:
    from shlex import quote  # type: ignore
except ImportError:
    from pipes import quote


def main():
    # type: () -> None
    setup_logging()

    args = parse_args()

    try:
        config = parse(args.basedir, "construi.yml")

        if args.list_targets:
            list_targets(config)
            sys.exit(0)

        target = args.target or config.default

        os.environ["CONSTRUI_ARGS"] = " ".join([quote(a) for a in args.construi_args])

        Target(config.for_target(target)).invoke(RunContext(config, args.dry_run))
    except Exception as e:
        on_exception(e)
    else:
        console.info("\nBuild Succeeded.\n")


def setup_logging():
    # type: () -> None
    root_logger = logging.getLogger()
    root_logger.addHandler(logging.StreamHandler(sys.stdout))
    root_logger.setLevel(logging.INFO)

    logging.getLogger("requests").propagate = False


def parse_args():
    # type: () -> Namespace
    parser = ArgumentParser(prog="construi", description="Run construi")

    parser.add_argument("--basedir", metavar="DIR", default=os.getcwd())
    parser.add_argument("-n", "--dry-run", action="store_true")
    parser.add_argument("-T", "--list-targets", action="store_true")
    parser.add_argument("-v", "--version", action="version", version=__version__)

    parser.add_argument("target", metavar="TARGET", nargs="?")
    parser.add_argument("construi_args", metavar="CONSTRUI_ARGS", nargs="*")

    return parser.parse_args()


def list_targets(config):
    # type: (Config) -> None
    targets = config.targets.keys() if config.targets else []

    for target in sorted(targets):
        print (target)
