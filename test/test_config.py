
from construi.config import Config, TargetConfig

from compose.config.types import VolumeSpec

import yaml

def test_for_target():
    working_dir = '/working/dir'

    yml = yaml.load("""
      image: java:latest

      targets:
        build:
          run: mvn install
    """)

    config = Config(yml, working_dir).for_target('build')

    expected_construi_config = {
        'before': [],
        'name': 'build',
        'run': ['mvn install']
    }

    expected_service_config = {
        'working_dir': working_dir,
        'volumes': [VolumeSpec(external=working_dir, internal=working_dir, mode='rw')],
        'name': 'build',
        'image': 'java:latest'
    }

    assert config == TargetConfig(expected_construi_config, [expected_service_config])

def test_volumes():
    working_dir = '/working/dir'

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

    config = Config(yml, working_dir).for_target('build')

    print(config)

    assert config.construi['run'] == ['run.sh']
    assert len(config.services) == 1
    assert VolumeSpec(external='/b', internal='/b', mode='rw') in config.services[0]['volumes']
    assert VolumeSpec(external='/a', internal='/a', mode='rw') in config.services[0]['volumes']
