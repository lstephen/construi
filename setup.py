from setuptools import setup

import codecs
import os
import re


def read(*parts):
    path = os.path.join(os.path.dirname(__file__), *parts)
    with codecs.open(path, encoding='utf-8') as fobj:
        return fobj.read()


def find_version():
    version_match = re.search(
        r"^__version__ = ['\"]([^'\"]*)['\"]",
        read('construi', '__version__.py'),
        re.M)

    if version_match:
        return version_match.group(1)

    raise RuntimeError("Unable to find version string.")


requires = {
    'install': [
        'PyYAML == 3.11',
        'docker-compose == 1.5.2'
    ],
    'setup': [
        'flake8 == 2.5.1',
        'pytest-runner == 2.6.2',
        'twine == 1.6.5'
    ],
    'tests': [
        'pytest == 2.8.5'
    ]
}

setup(
    name='construi',
    version=find_version(),
    zip_safe=False,

    packages=['construi'],

    install_requires=requires['install'],
    setup_requires=requires['setup'],
    tests_require=requires['tests'],

    entry_points={
        'console_scripts': [
            'construi=construi.cli:main',
        ]
    },
)
