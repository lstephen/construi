import os
import os.path
import shlex
import sys
from typing import Any, List, Optional, Set, Union

import construi.console as console
import dockerpty
from compose.cli.docker_client import docker_client
from compose.project import Project
from compose.service import ConvergenceStrategy

from .config import Config, ConfigException, TargetConfig


class BuildFailedException(Exception):
    def __init__(self):
        # type: () -> None
        pass


class Target(object):
    def __init__(self, config):
        # type: (TargetConfig) -> None
        self.config = config
        self.project = Project.from_config(
            "construi_%s" % self.config.construi.project_name,
            config.compose,
            docker_client(os.environ, version="auto"),
        )

    @property
    def before(self):
        # type: () -> List[str]
        return self.config.construi.before

    @property
    def client(self):
        # type: () -> Any
        return self.project.client

    @property
    def commands(self):
        # type: () -> List[str]
        return self.config.construi.run

    @property
    def name(self):
        # type: () -> str
        return self.config.construi.name

    @property
    def shell(self):
        # type: () -> Optional[str]
        return self.config.construi.shell

    @property
    def service(self):
        # type: () -> Any
        return self.project.get_service(self.name)

    @property
    def linked_services(self):
        # type: () -> Any
        return [s for s in self.project.service_names if s != self.name]

    def invoke(self, run_ctx):
        # type: (RunContext) -> None
        console.progress("** Invoke %s" % self.name)

        if run_ctx.is_executed(self.name):
            console.progress("** Skipped %s" % self.name)
            return

        if run_ctx.is_invoked(self.name):
            raise ConfigException(
                "Cyclic dependency detected when invoking {}".format(self.name)
            )

        run_ctx.mark_invoked(self.name)

        for target in self.before:
            Target(run_ctx.config.for_target(target)).invoke(run_ctx)

        if self.commands:
            dry_run = "(dry run)" if run_ctx.dry_run else ""
            console.progress("** Execute %s %s" % (self.name, dry_run))

            if not run_ctx.dry_run:
                self.run()

        run_ctx.mark_executed(self.name)

    def run(self):
        # type: () -> None
        try:
            self.setup()

            self.start_linked_services()

            for command in self.commands:
                self.run_command(command)

            console.progress("Done.")

        finally:
            self.cleanup()

    def run_command(self, command):
        # type: (str) -> None
        if self.shell:
            to_run = shlex.split(self.shell) + [command]  # type: Union[str, List[str]]
            console.progress("(%s)> %s" % (self.shell, command))
        else:
            to_run = command
            console.progress("> %s" % command)

        container = self.service.create_container(
            one_off=True, command=to_run, tty=False, stdin_open=True, detach=False
        )

        try:
            dockerpty.start(self.client, container.id, interactive=False)

            if container.wait() != 0:
                raise BuildFailedException()
                sys.exit(1)

        finally:
            self.client.remove_container(container.id, force=True)

    def setup(self):
        # type: () -> None
        console.progress("Building Images...")
        self.project.build()

        console.progress("Pulling Images...")
        self.project.pull()

        self.project.initialize()

    def start_linked_services(self):
        # type: () -> None
        if self.linked_services:
            self.project.up(
                service_names=self.linked_services,
                start_deps=True,
                strategy=ConvergenceStrategy.always,
            )

    def cleanup(self):
        # type: () -> None
        console.progress("Cleaning up...")
        self.project.kill()
        self.project.remove_stopped(None, v=True)
        self.project.networks.remove()


class RunContext(object):
    def __init__(self, config, dry_run=False):
        # type: (Config, bool) -> None
        self.config = config
        self.dry_run = dry_run
        self.executed = set()  # type: Set[str]
        self.invoked = set()  # type: Set[str]

    def mark_invoked(self, target):
        # type: (str) -> None
        self.invoked.add(target)

    def is_invoked(self, target):
        # type: (str) -> bool
        return target in self.invoked

    def mark_executed(self, target):
        # type: (str) -> None
        self.executed.add(target)

    def is_executed(self, target):
        # type: (str) -> bool
        return target in self.executed
