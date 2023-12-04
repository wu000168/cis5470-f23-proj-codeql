import sys
from __init__ import tainted_input, sanitizer, not_sanitizer

def branch1(*args):
    x = tainted_input()
    if (len(args) > 2):
        x = 0
        y = sanitizer(x)
    else:
        y = not_sanitizer(x)
    z = 4 / y  # alarm


if __name__ == '__main__':
    import sys
    branch1(sys.argv)
