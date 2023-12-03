def raise_variable():
    try:
        x = Exception("This is an exception")
        raise x
    except Exception:
        pass


def raise_variable_alias():
    try:
        x = Exception("This is an exception")
        y = x
        raise y
    except Exception:
        pass


def raise_variable_conditional():
    x = ValueError("This is a value error")
    if True:
        y = x
    else:
        y = NotImplementedError("This is a not implemented error")
    raise y


def catch_all_variables():
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
        x = ValueError("This is a value error")
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
        x = ValueError("This is a value error")
        y = NotImplementedError("This is a not implemented error")
        if True:
            raise x
        else:
            raise y
    except NotImplementedError as e:
        # ValueError is not caught
        pass


def except_a_variable():
    e = Exception
    try:
        raise Exception()
    except e:
        pass
