from __init__ import tainted_input, sanitizer, not_sanitizer

def branch0(*args):
    if (len(args) > 2):
        x = 0
        y = x
    else:
        x = tainted_input()
        y = x

    z = 4 / y  # alarm


if __name__ == '__main__':
    import sys
    branch0(sys.argv)
