from .config import parse
from .target import RunContext
from .target import Target
from .__version__ import __version__

from argparse import ArgumentParser

from compose.errors import OperationFailedError

import construi.console as console
import construi.utils as utils

import logging
import os
import sys
import traceback
import yaml
import docker


def main():
    setup_logging()

    args = parse_args()

    config = parse(args.basedir, 'construi.yml')

    if args.list_targets:
        list_targets(config)
        sys.exit(0)

    if args.clean_images:
        clean_images(args.basedir)
        sys.exit(0)

    target = args.target or config.default

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
    parser.add_argument('-C', '--clean-images', action='store_true')
    parser.add_argument(
        '-v', '--version', action='version', version=__version__)

    parser.add_argument('target', metavar='TARGET', nargs='?')

    return parser.parse_args()


def list_targets(config):
    targets = config.targets.keys()

    targets.sort()

    for target in targets:
        print(target)


def clean_images(working_dir):
    remaining_images = {}

    yml = utils.load_images_names(working_dir)

    if not yml:
        console.info('Nothing to clean, quit')
        sys.exit(0)

    client = docker.from_env()

    for target in yml:
        for name in yml[target]:
            console.progress("Cleaning %s ..." % name)

            try:
                client.images.remove(name)
            except:
                console.error("Failed to remove image %s" % name)
                if target not in remaining_images:
                    remaining_images[target] = []

                remaining_images[target].append(name)
                continue

            console.info("Succeed to remove image %s" % name)

    utils.save_images_names_to_file(working_dir, remaining_images)
