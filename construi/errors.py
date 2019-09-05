import sys
import traceback
from typing import Any, Callable, Dict, NoReturn

import construi.console as console
from compose.errors import OperationFailedError
from compose.service import BuildError
from docker.errors import APIError

from .config import ConfigException, NoSuchTargetException
from .target import BuildFailedException


def show_error(fmt, arg=lambda e: "", show_traceback=False):
    # type: (str, Callable[[Any], Any], bool) -> Callable[[Exception], None]
    def f(e):
        # type: (Exception) -> None
        console.error(("\n" + fmt + "\n").format(arg(e)))

        if show_traceback:
            traceback.print_exc()

    return f


def on_keyboard_interrupt(e):
    # type: (KeyboardInterrupt) -> None
    console.warn("\nBuild Interrupted.")


def on_unhandled_exception(e):
    # type: (Exception) -> NoReturn
    raise e


HANDLERS = {
    KeyboardInterrupt: on_keyboard_interrupt,
    APIError: show_error("Docker Error: {}", lambda e: e.explanation),
    OperationFailedError: show_error(
        "Unexpected Error: {}", lambda e: e.msg, show_traceback=True
    ),
    BuildError: show_error("Error building docker image."),
    NoSuchTargetException: show_error("No such target: {}", lambda e: e.target),
    ConfigException: show_error("Configuration Error: {}", lambda e: e.msg),
    BuildFailedException: show_error("Build Failed."),
}  # type: Dict[Any, Callable[[Any], None]]


def on_exception(e):
    # type: (Exception) -> NoReturn
    HANDLERS.get(type(e), on_unhandled_exception)(e)
    sys.exit(1)
