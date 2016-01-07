
import construi.console as console

from compose.project import Project
from compose.cli.docker_client import docker_client

import dockerpty
import sys


class Target(object):
    def __init__(self, config):
        self.config = config
        self.project = Project.from_dicts(
            'construi', config.services, docker_client())

    def run(self):
        try:
            self.setup()

            service = self.project.get_service(self.config.construi['name'])

            for cmd in self.config.construi['run']:
                console.progress("> %s" % cmd)

                container = service.create_container(
                    one_off=True,
                    command=cmd,
                    tty=False,
                    stdin_open=True,
                    detach=False
                )

                dockerpty.start(
                    self.project.client, container.id, interactive=False)
                exit_code = container.wait()
                self.project.client.remove_container(container.id, force=True)

                if exit_code != 0:
                    console.error("\nBuild Failed.")
                    sys.exit(1)

            console.progress('Done.')
        except KeyboardInterrupt:
            console.warn("\nBuild Interrupted.")
            sys.exit(1)

        finally:
            self.cleanup()

    def setup(self):
        console.progress('Building Images...')
        self.project.build()

        console.progress('Pulling Images...')
        self.project.pull()

    def cleanup(self):
        console.progress('Cleaning up...')
        self.project.kill()
        self.project.remove_stopped(None, v=True)
