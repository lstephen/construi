import shutil
import tempfile


def before_scenario(context, scenario):
    context.working_directory = tempfile.mkdtemp()


def after_scenario(context, scenario):
    shutil.rmtree(context.working_directory)
