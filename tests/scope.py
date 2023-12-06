def top_level():
    # SHOULD BE in the output
    raise Exception("I am an exception")


def in_condition():
    # SHOULD BE in the output
    if True:
        raise Exception("I am an exception")


def in_loop():
    # SHOULD BE in the output
    for i in range(10):
        raise Exception("I am an exception")


def in_inner_function():
    # SHOULD BE in the output
    def inner_function():
        raise Exception("I am an exception")

    inner_function()


def raise_in_try():
    # SHOULD NOT BE in the output
    try:
        raise Exception("I am an exception")
    except Exception:
        pass


def raise_in_catch():
    try:
        # SHOULD NOT BE in the output
        raise Exception("I am an exception")
    except Exception:
        # SHOULD BE in the output
        raise Exception("I am an exception")


def one_caught_one_uncaught():
    try:
        # SHOULD NOT BE in the output
        raise Exception("I am an exception")
    except Exception:
        pass

    # SHOULD BE in the output
    raise Exception("I am an exception")
