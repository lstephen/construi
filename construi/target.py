import construi.console as console
import construi.utils as utils

from compose.project import Project
from compose.cli.docker_client import docker_client
from compose.service import ConvergenceStrategy

import dockerpty
import random
import sys
import os


def generate_build_id():
    v = 'aeiou'
    c = 'bdfghjklmnprstvw'

    return ''.join([random.choice(v if i % 2 else c) for i in range(8)])


class Target(object):
    def __init__(self, config):
        self.config = config
        self.project = Project.from_config("construi_%s" % Target.build_id(),
                                           config.compose,
                                           docker_client(os.environ))

    @classmethod
    def build_id(cls):
        try:
            return cls._build_id
        except AttributeError:
            cls._build_id = generate_build_id()
            return cls._build_id

    @property
    def before(self):
        return self.config.construi['before']

    @property
    def client(self):
        return self.project.client

    @property
    def commands(self):
        return self.config.construi.get('run', [])

    @property
    def name(self):
        return self.config.construi['name']

    @property
    def service(self):
        return self.project.get_service(self.name)

    @property
    def linked_services(self):
        return [s for s in self.project.service_names if s != self.name]

    def invoke(self, run_ctx):
        console.progress("** Invoke %s" % self.name)

        for target in self.before:
            Target(run_ctx.config.for_target(target)).invoke(run_ctx)

        if run_ctx.is_executed(self.name):
            console.progress("** Skipped %s" % self.name)
            return

        if self.commands:
            dry_run = '(dry run)' if run_ctx.dry_run else ''
            console.progress("** Execute %s %s" % (self.name, dry_run))

            if not run_ctx.dry_run:
                self.run()

        run_ctx.mark_executed(self.name)

    def run(self):
        try:
            self.setup()

            self.start_linked_services()

            for command in self.commands:
                self.run_command(command)

            console.progress('Done.')

        except KeyboardInterrupt:
            console.warn("\nBuild Interrupted.")
            sys.exit(1)

        finally:
            self.cleanup()

    def run_command(self, command):
        console.progress("> %s" % command)

        container = self.service.create_container(
            one_off=True,
            command=command,
            tty=False,
            stdin_open=True,
            detach=False)

        try:
            dockerpty.start(self.client, container.id, interactive=False)

            if container.wait() != 0:
                console.error("\nBuild Failed.")
                sys.exit(1)

        finally:
            self.client.remove_container(container.id, force=True)

    def setup(self):
        console.progress('Building Images...')
        self.project.build()

        console.progress('Pulling Images...')
        self.project.pull()

        self.project.initialize()

    def start_linked_services(self):
        if self.linked_services:
            self.project.up(service_names=self.linked_services,
                            start_deps=True,
                            strategy=ConvergenceStrategy.always)

    def save_image_name(self):
        yml = utils.load_images_names(self.config.construi['working_dir'])
        if self.name not in yml:
            yml[self.name] = []
        yml[self.name].append('%s_%s' % (self.project.name, self.name))
        utils.save_images_names_to_file(self.config.construi['working_dir'], yml)

    def cleanup(self):
        console.progress('Cleaning up...')
        self.project.kill()
        self.project.remove_stopped(None, v=True)
        self.project.networks.remove()
        self.save_image_name()


class RunContext(object):
    def __init__(self, config, dry_run=False):
        self.config = config
        self.dry_run = dry_run
        self.executed = set()

    def mark_executed(self, target):
        self.executed.add(target)

    def is_executed(self, target):
        return target in self.executed
