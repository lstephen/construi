from .config import parse
from .target import Target

from argparse import ArgumentParser

import logging
import os
import sys


def main():
    setup_logging()

    parser = ArgumentParser(description='Run construi')

    parser.add_argument('target', metavar='TARGET')
    parser.add_argument('--basedir', metavar='DIR', default=os.getcwd())

    args = parser.parse_args()

    config = parse(args.basedir, 'construi.yml')

    config.for_target(args.target)

    Target(config.for_target(args.target)).run()

def setup_logging():
    root_logger = logging.getLogger()
    root_logger.addHandler(logging.StreamHandler(sys.stdout))
    root_logger.setLevel(logging.INFO)

