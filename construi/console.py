from compose.cli import colors


def error(msg):
    print(colors.red(msg))


def warn(msg):
    print(colors.yellow(msg))


def info(msg):
    print(colors.green(msg))


def progress(msg):
    info("\n%s" % msg)
