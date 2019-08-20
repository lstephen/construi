import codecs
import os

from setuptools import find_packages, setup


def read(*parts):
    path = os.path.join(os.path.dirname(__file__), *parts)
    with codecs.open(path, encoding="utf-8") as fobj:
        return fobj.read()


def find_version():
    with open("VERSION") as f:
        return f.read()


def install_requires():
    with open("requirements.txt") as f:
        return [r.strip() for r in f.readlines()]


requires = {
    "install": install_requires(),
    "setup": ["pytest-runner == 2.6.2"],
    "tests": ["pytest == 2.8.5", "pytest-cov == 2.2.0"],
}

summary = "Use Docker to define your build environment"

setup(
    name="construi",
    version=find_version(),
    url="https://github.com/lstephen/construi",
    license="Apache License 2.0",
    description=summary,
    long_description=summary,
    author="Levi Stephen",
    author_email="levi.stephen@gmail.com",
    zip_safe=True,
    packages=find_packages(),
    install_requires=requires["install"],
    setup_requires=requires["setup"],
    tests_require=requires["tests"],
    entry_points={"console_scripts": ["construi=construi.cli:main"]},
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
    ],
)
