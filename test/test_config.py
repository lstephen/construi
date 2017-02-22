from construi.config import Config, NoSuchTargetException, TargetConfig

from compose.config.types import VolumeSpec

import os
import pytest
import sys
import yaml


class TestConfig(object):
    @property
    def working_dir(self):
        return os.path.dirname(os.path.realpath(__file__))

    def config(self, yml, target):
        return Config(yml, self.working_dir).for_target(target)

    def test_for_target(self):
        yml = yaml.load("""
          image: java:latest

          targets:
            build: mvn install
        """)

        config = self.config(yml, 'build')

        assert config.construi['before'] == []
        assert config.construi['name'] == 'build'
        assert config.construi['run'] == ['mvn install']

        assert len(config.services) == 1

        service = config.services[0]
        assert service['working_dir'] == self.working_dir
        assert service['name'] == 'build'
        assert service['image'] == 'java:latest'
        assert service['volumes'] == [
            VolumeSpec(
                external=self.working_dir,
                internal=self.working_dir,
                mode='rw')
        ]

    def test_no_such_target(self):
        yml = yaml.load("""
          image: java:latest

          targets:
            build: mvn install
        """)

        with pytest.raises(NoSuchTargetException):
            config = self.config(yml, 'does_not_exist')

    def test_build_and_image_handling(self):
        yml = yaml.load("""
          image: java:latest

          targets:
            target:
              build: Dockerfile.dummy
        """)

        config = self.config(yml, 'target')

        assert len(config.services) == 1

        service = config.services[0]
        assert 'image' not in service
        assert service['build'] == {
            'context': os.path.join(self.working_dir, 'Dockerfile.dummy')
        }

    def test_no_run(self):
        yml = yaml.load("""
          image: java:latest

          targets:
            build:
              before:
                - a
                - b
        """)

        config = self.config(yml, 'build')

        assert config.construi['before'] == ['a', 'b']
        assert config.construi['run'] == []

    def test_volumes(self):
        yml = yaml.load("""
          image: java:latest
          volumes:
            - /a:/a

          targets:
            build:
              volumes:
                - /b:/b
              run: run.sh
        """)

        config = self.config(yml, 'build')

        assert config.construi['run'] == ['run.sh']
        assert len(config.services) == 1
        assert VolumeSpec(
            external='/b', internal='/b',
            mode='rw') in config.services[0]['volumes']
        assert VolumeSpec(
            external='/a', internal='/a',
            mode='rw') in config.services[0]['volumes']

    def test_links(self):
        yml = yaml.load("""
            image: java:latest

            targets:
              build:
                run: run.sh
                links:
                  mysql:
                    image: mysql:latest
        """)

        config = self.config(yml, 'build')

        print(config)

        assert config.construi['run'] == ['run.sh']
        assert len(config.services) == 2

        build = get_service(config, 'build')
        assert build['links'] == ['mysql']
        assert build['image'] == 'java:latest'

        mysql = get_service(config, 'mysql')
        assert mysql['image'] == 'mysql:latest'


def get_service(target_config, name):
    return next(s for s in target_config.services if s['name'] == name)
