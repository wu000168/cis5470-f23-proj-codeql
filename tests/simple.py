def raises():
    raise Exception("This is an exception")


def raises_and_caught():
    try:
        raise Exception("This is an exception")
    except Exception as e:
        pass


def raises_valueerror_and_caught():
    try:
        raise ValueError("This is a value error")
    except ValueError as e:
        pass


def normal():
    a = 1 + 1
