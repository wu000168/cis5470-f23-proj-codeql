def test():
    # SHOULD BE in the output
    raise Exception("This is an exception")


def caught():
    # SHOULD NOT BE in the output
    try:
        test()
    except Exception as e:
        pass


def uncaught():
    # SHOULD BE in the output
    test()


def indirect_caught():
    # SHOULD NOT BE in the output
    try:
        uncaught()
    except Exception as e:
        pass


def indirect_uncaught():
    # SHOULD BE in the output
    uncaught()
