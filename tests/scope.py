def top_level():
    raise Exception("I am an exception")


def in_condition():
    if True:
        raise Exception("I am an exception")


def in_loop():
    for i in range(10):
        raise Exception("I am an exception")


def in_inner_function():
    def inner_function():
        raise Exception("I am an exception")

    inner_function()


def raise_in_try():
    try:
        raise Exception("I am an exception")
    except Exception:
        pass


def raise_in_catch():
    try:
        raise Exception("I am an exception")
    except Exception:
        raise Exception("I am an exception")


def one_caught_one_uncaught():
    try:
        raise Exception("I am an exception")
    except Exception:
        pass

    raise Exception("I am an exception")
