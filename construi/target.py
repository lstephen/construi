
import construi.console as console

from compose.project import Project
from compose.cli.docker_client import docker_client
from compose.cli.main import run_one_off_container

import dockerpty

class Target(object):
    def __init__(self, config):
        self.config = config

    def run(self):
        project = self.create_project()

        try:
            console.progress('Building Images...')
            project.build()

            console.progress('Pulling Images...')
            project.pull()

            #project.up()

            service = project.get_service(self.config.construi['name'])

            for cmd in self.config.construi['run']:
                console.progress("> %s" % cmd)
                container = service.create_container(one_off=True, command=cmd, tty=False, stdin_open=True, detach=False)
                dockerpty.start(project.client, container.id, interactive=False)
                container.wait()
                project.client.remove_container(container.id, force=True)

        finally:
            console.progress('Cleaning up...')
            project.kill()
            project.remove_stopped(None, v=True)

        console.progress('Done.')

    def create_project(self):
        return Project.from_dicts('construi', self.config.services, docker_client())

