from __init__ import tainted_input, sanitizer, not_sanitizer

def branch2():
    x = tainted_input()
    if (1):
        y = 0
    else:
        y = 100
    z = 4 / y


if __name__ == '__main__':
    branch2()
