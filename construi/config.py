
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

    def __getattr__(self, name):
        return self.yml[name]

    def for_target(self, target):
        config_files = [
            self.base_config(target),
            self.target_config(target),
            self.workspace_config(target)
        ]

        config_details = compose.ConfigDetails(self.working_dir, config_files)

        target_yml = self.target_yml(target)

        construi = {
            'before': target_yml['before'] if 'before' in target_yml else [],
            'name': target,
            'run': self.target_yml(target).get('run', [])
        }

        return TargetConfig(construi, compose.load(config_details))

    def base_config(self, name):
        base_yml = dict(self.yml)

        delete(base_yml, 'default', 'targets')

        return compose.ConfigFile(self.filename, {name: base_yml})

    def target_config(self, target):
        target_yml = self.target_yml(target)

        services = self.get_links(target_yml)

        delete(target_yml, 'before', 'links', 'run')

        target_yml['links'] = [s for s in services.keys()]

        services[target] = target_yml

        return compose.ConfigFile(self.filename, services)

    def target_yml(self, target):
        yml = self.yml['targets'][target]

        if type(yml) is str:
            yml = {'run': [yml]}
        if 'run' in yml and type(yml['run']) is str:
            yml['run'] = [yml['run']]

        return yml.copy()

    def get_links(self, yml):
        links = {}

        if 'links' in yml:
            links = yml['links']

        return links

    def workspace_config(self, name):
        config = {
            'working_dir': self.working_dir,
            'volumes': [
                "%s:%s" % (self.working_dir, self.working_dir)
            ]
        }

        return compose.ConfigFile(self.filename, {name: config})


class TargetConfig(namedtuple('_TargetConfig', 'construi services')):
    pass


def delete(hsh, *keys):
    for key in keys:
        if key in hsh:
            del hsh[key]
