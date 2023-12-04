from __init__ import tainted_input, sanitizer, not_sanitizer

def loop1():
    y = tainted_input()
    x = 0
    while (x > 0):
        y = sanitizer(y)
    z = 4 / y  # alarm


if __name__ == '__main__':
    loop1()
