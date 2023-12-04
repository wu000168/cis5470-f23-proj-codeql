from __init__ import tainted_input, sanitizer, not_sanitizer

def simple1():
    x = tainted_input()
    y = sanitizer(x)
    z = 4 / y  # safe

    y = not_sanitizer(x)
    z = 4 / y  # alarm
    return 0


if __name__ == '__main__':
    simple1()
