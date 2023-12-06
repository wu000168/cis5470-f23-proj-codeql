def raises():
    # SHOULD BE in the output
    raise Exception("This is an exception")


def raises_and_caught():
    # SHOULD NOT BE in the output
    try:
        raise Exception("This is an exception")
    except Exception as e:
        pass


def raises_valueerror_and_caught():
    # SHOULD NOT BE in the output
    try:
        raise ValueError("This is a value error")
    except ValueError as e:
        pass


def normal():
    # SHOULD NOT BE in the output
    a = 1 + 1
