from compose.cli import colors


def error(msg):
    # type: (str) -> None
    print (colors.red(msg))


def warn(msg):
    # type: (str) -> None
    print (colors.yellow(msg))


def info(msg):
    # type: (str) -> None
    print (colors.green(msg))


def progress(msg):
    # type: (str) -> None
    info("\n%s" % msg)
