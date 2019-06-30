from behave import *

import shlex
import subprocess


@when("running {command}")
def running(context, command):
    output = subprocess.check_output(shlex.split(command), stderr=subprocess.STDOUT)

    if isinstance(output, bytes):
        output = output.decode("utf-8")

    context.output = output


@then("it outputs the version")
def outputs_version(context):
    with open("VERSION") as v:
        expected_version = v.read()

    assert context.output == expected_version
