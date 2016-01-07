
import compose.config.config as compose

import os
import yaml

from collections import namedtuple


def parse(working_dir, f):
    with open(os.path.join(working_dir, f), 'r') as config_file:
        return Config(yaml.safe_load(config_file), working_dir, f)


class Config(object):
    def __init__(self, yml, working_dir=os.getcwd(), filename='construi.yml'):
        self.yml = yml
        self.working_dir = working_dir
        self.filename = filename

    def for_target(self, target):
        config_files = [
            self.base_config(target),
            self.target_config(target),
            self.workspace_config(target)
        ]

        config_details = compose.ConfigDetails(self.working_dir, config_files)

        construi = {'run': self.target_yml(target)['run'], 'name': target}

        return TargetConfig(construi, compose.load(config_details))

    def base_config(self, name):
        base_yml = dict(self.yml)
        del base_yml['targets']
        return compose.ConfigFile(self.filename, {name: base_yml})

    def target_config(self, target):
        target_yml = self.target_yml(target)

        del target_yml['run']

        return compose.ConfigFile(self.filename, {target: target_yml})

    def workspace_config(self, name):
        config = {
            'working_dir': self.working_dir,
            'volumes': [
                "%s:%s" % (self.working_dir, self.working_dir)
            ]
        }

        return compose.ConfigFile(self.filename, {name: config})

    def target_yml(self, target):
        yml = self.yml['targets'][target]

        if type(yml) is str:
            yml = {'run': [yml]}
        if type(yml['run']) is str:
            yml = {'run': [yml['run']]}

        return yml.copy()


class TargetConfig(namedtuple('_TargetConfig', 'construi services')):
    pass
