def raise_variable():
    # SHOULD NOT be in the output
    try:
        x = Exception("This is an exception")
        raise x
    except Exception:
        pass


def raise_variable_alias():
    # SHOULD NOT be in the output
    try:
        x = Exception("This is an exception")
        y = x
        raise y
    except Exception:
        pass


def catch_all_variables():
    # SHOULD NOT be in the output
    try:
        x = ValueError("This is a value error")
        y = NotImplementedError("This is a not implemented error")
        if True:
            raise x
        else:
            raise y
    except Exception as e:
        pass


def catch_one_variable():
    try:
        # SHOULD NOT BE in the output
        x = ValueError("This is a value error")

        # SHOULD BE in the output
        y = NotImplementedError("This is a not implemented error")

        if True:
            raise x
        else:
            raise y
    except ValueError as e:
        # NotImplementedError is not caught
        pass


def catch_other_variable():
    try:
        # SHOULD BE in the output
        x = ValueError("This is a value error")

        # SHOULD NOT BE in the output
        y = NotImplementedError("This is a not implemented error")

        if True:
            raise x
        else:
            raise y
    except NotImplementedError as e:
        # ValueError is not caught
        pass


def except_a_variable():
    # SHOULD NOT BE in the output
    e = Exception
    try:
        raise Exception()
    except e:
        pass
