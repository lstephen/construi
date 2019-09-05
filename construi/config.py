import os
import os.path
from typing import Any, Dict, List, Optional

import compose.config.config as compose
import yaml
from yaml import YAMLError


def parse(working_dir, f):
    # type: (str, str) -> Config
    try:
        with open(os.path.join(working_dir, f), "r") as config_file:
            return Config(yaml.safe_load(config_file), working_dir, f)
    except IOError:
        raise ConfigException("Could not read construi.yml")
    except YAMLError as e:
        raise ConfigException(str(e))


class NoSuchTargetException(Exception):
    def __init__(self, target):
        # type: (str) -> None
        self.target = target


class ConfigException(Exception):
    def __init__(self, msg):
        # type: (str) -> None
        self.msg = msg


class Config(object):
    def __init__(self, yml, working_dir=os.getcwd(), filename="construi.yml"):
        # type: (Dict[str, Any], str, str) -> None
        self.yml = yml or {}
        self.working_dir = working_dir
        self.filename = filename

    def __getattr__(self, name):
        # type: (str) -> Any
        return self.yml[name]

    @property
    def default(self):
        # type: () -> str
        try:
            default = self.yml["default"]
        except KeyError:
            raise ConfigException("No default target configured")
        else:
            if not isinstance(default, str):
                raise ConfigException("default must be a single target name")
            return default

    @property
    def project_name(self):
        # type: () -> str
        return os.path.basename(self.working_dir).lower()

    def for_target(self, target):
        # type: (str) -> TargetConfig
        config_files = [
            self.base_config(target),
            self.target_config(target),
            self.workspace_config(target),
        ]

        config_details = compose.ConfigDetails(self.working_dir, config_files)

        target_yml = self.target_yml(target)

        construi = ConstruiConfig(
            before=target_yml["before"] if "before" in target_yml else [],
            name=target,
            run=target_yml.get("run", []),
            shell=target_yml.get("shell", None),
            project_name=self.project_name,
        )

        return TargetConfig(construi, compose.load(config_details))

    def base_config(self, target):
        # type: (str) -> compose.ConfigFile
        base_yml = dict(self.yml)

        delete(base_yml, "default", "targets")

        base_yml["environment"] = base_yml.get("environment", []) + ["CONSTRUI_ARGS"]

        # If the target specified build and/or image remove it from base.
        # IMO this behavior is more intuitive for construi than the default
        # merging behavior of the compose v2 schema.
        target_yml = self.target_yml(target)

        if "build" in target_yml or "image" in target_yml:
            delete(base_yml, "build", "image")

        return self.create_config_file({target: base_yml})

    def target_config(self, target):
        # type: (str) -> compose.ConfigFile
        target_yml = self.target_yml(target)

        services = self.get_links(target_yml)

        delete(target_yml, "before", "links", "run", "shell")

        target_yml["links"] = [s for s in services.keys()]

        services[target] = target_yml

        return self.create_config_file(services)

    def target_yml(self, target):
        # type: (str) -> Any
        try:
            if not self.yml["targets"]:
                raise NoSuchTargetException(target)

            yml = self.yml["targets"][target]
        except KeyError:
            raise NoSuchTargetException(target)

        if type(yml) is str:
            yml = {"run": [yml]}
        if "run" in yml and type(yml["run"]) is str:
            yml["run"] = [yml["run"]]
        if "run" in yml and yml["run"] is None:
            yml["run"] = [""]

        return yml.copy()

    def get_links(self, yml):
        # type: (Dict[str, Any]) -> Dict[str, Any]
        links = {}  # type: Dict[str, Any]

        if "links" in yml:
            links = yml["links"]

        return links

    def workspace_config(self, name):
        # type: (str) -> compose.ConfigFile
        config = {
            "working_dir": self.working_dir,
            "volumes": ["%s:%s" % (self.working_dir, self.working_dir)],
        }

        return self.create_config_file({name: config})

    def create_config_file(self, yml):
        # type: (Any) -> compose.ConfigFile
        return compose.ConfigFile(self.filename, {"version": "3", "services": yml})


class ConstruiConfig(object):
    def __init__(
        self,
        before,  # type: List[str]
        name,  # type: str
        run,  # type: List[str]
        shell,  # type: Optional[str]
        project_name,  # type: str
    ):
        # type: (...) -> None
        self.before = before
        self.name = name
        self.run = run
        self.shell = shell
        self.project_name = name


class TargetConfig(object):
    def __init__(self, construi, compose):
        # type: (ConstruiConfig, compose.Config) -> None
        self.construi = construi
        self.compose = compose

    @property
    def services(self):
        # type: () -> Any
        return self.compose.services


def delete(hsh, *keys):
    # type: (Dict[str, Any], *str) -> None
    for key in keys:
        if key in hsh:
            del hsh[key]
