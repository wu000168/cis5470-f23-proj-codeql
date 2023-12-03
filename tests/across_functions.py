def test():
    raise Exception("This is an exception")


def caught():
    try:
        test()
    except Exception as e:
        pass


def uncaught():
    test()


def indirect_caught():
    try:
        uncaught()
    except Exception as e:
        pass


def indirect_uncaught():
    uncaught()
