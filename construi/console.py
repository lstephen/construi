from compose.cli import colors

def info(msg):
    print(colors.green(msg))

def progress(msg):
    info("\n%s" % msg)

