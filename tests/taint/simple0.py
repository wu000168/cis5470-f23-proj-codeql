from __init__ import tainted_input, sanitizer, not_sanitizer

def simple0():
    x = tainted_input()
    y = x
    z = 4 / y  # alarm

    return 0


if __name__ == '__main__':
    simple0()
