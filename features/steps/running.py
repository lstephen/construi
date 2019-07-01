from behave import *

import contextlib
import os
import shlex
import subprocess


@contextlib.contextmanager
def pushd(new_dir):
    old_dir = os.getcwd()
    os.chdir(new_dir)
    yield
    os.chdir(old_dir)


@given("a {file_name} file")
def create_file(context, file_name):
    with pushd(context.working_directory):
        with open(file_name, "w") as f:
            f.write(context.text)


@when("running {command}")
def running(context, command):
    with pushd(context.working_directory):
        try:
            output = subprocess.check_output(
                shlex.split(command), stderr=subprocess.STDOUT
            )
            context.exit_code = 0

        except subprocess.CalledProcessError as err:
            output = err.output
            context.exit_code = err.returncode

        if isinstance(output, bytes):
            output = output.decode("utf-8")

        context.output = output


@then("it has an exit code of {exit_code:d}")
def exits_with(context, exit_code):
    assert context.exit_code == exit_code, "Expected: %d. Got %d. Output was: %s" % (
        exit_code,
        context.exit_code,
        context.output,
    )


@then("it outputs the version")
def outputs_version(context):
    with open("VERSION") as v:
        expected_version = v.read()

    assert context.output == expected_version, "Expected: '%s'. Got: '%s'." % (
        expected_version,
        context.output,
    )


@then("it outputs")
def outputs(context):
    assert context.output == context.text, "Expected: '%s'. Got: '%s'." % (
        context.text,
        context.output,
    )
