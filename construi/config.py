import compose.config.config as compose

import os
import yaml

import os.path

from collections import namedtuple


def parse(working_dir, f):
    with open(os.path.join(working_dir, f), 'r') as config_file:
        return Config(yaml.safe_load(config_file), working_dir, f)


class NoSuchTargetException(Exception):
    def __init__(self, target):
        self.target = target


class Config(object):
    def __init__(self, yml, working_dir=os.getcwd(), filename='construi.yml'):
        self.yml = yml
        self.working_dir = working_dir
        self.filename = filename

    def __getattr__(self, name):
        return self.yml[name]

    @property
    def project_name(self):
        return os.path.basename(self.working_dir)

    def for_target(self, target):
        config_files = [
            self.base_config(target), self.target_config(target),
            self.workspace_config(target)
        ]

        config_details = compose.ConfigDetails(self.working_dir, config_files)

        target_yml = self.target_yml(target)

        construi = {
            'before': target_yml['before'] if 'before' in target_yml else [],
            'name': target,
            'run': self.target_yml(target).get('run', []),
            'shell': self.target_yml(target).get('shell', None),
            'project_name': self.project_name
        }

        return TargetConfig(construi, compose.load(config_details))

    def base_config(self, target):
        base_yml = dict(self.yml)

        delete(base_yml, 'default', 'targets')

        # If the target specified build and/or image remove it from base.
        # IMO this behavior is more intuitive for construi than the default
        # merging behavior of the compose v2 schema.
        target_yml = self.target_yml(target)

        if 'build' in target_yml or 'image' in target_yml:
            delete(base_yml, 'build', 'image')

        return self.create_config_file({target: base_yml})

    def target_config(self, target):
        target_yml = self.target_yml(target)

        services = self.get_links(target_yml)

        delete(target_yml, 'before', 'links', 'run', 'shell')

        target_yml['links'] = [s for s in services.keys()]

        services[target] = target_yml

        return self.create_config_file(services)

    def target_yml(self, target):
        try:
            yml = self.yml['targets'][target]
        except KeyError:
            raise NoSuchTargetException(target)

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
            'volumes': ["%s:%s" % (self.working_dir, self.working_dir)]
        }

        return self.create_config_file({name: config})

    def create_config_file(self, yml):
        return compose.ConfigFile(self.filename,
                                  {'version': '2',
                                   'services': yml})


class TargetConfig(namedtuple('_TargetConfig', 'construi compose')):
    @property
    def services(self):
        return self.compose.services


def delete(hsh, *keys):
    for key in keys:
        if key in hsh:
            del hsh[key]
