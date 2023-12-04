from __init__ import tainted_input, sanitizer, not_sanitizer

def loop0(*args):
    x = 0
    while (len(args) > 1):
        x = tainted_input()
        y = x
        argc -= 1
    z = 4 / y  # alarm


if __name__ == '__main__':
    import sys
    loop0(sys.argv)
