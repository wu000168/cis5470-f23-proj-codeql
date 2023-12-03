def raise_variable():
    x = Exception("This is an exception")
    raise x


def raise_variable_alias():
    x = Exception("This is an exception")
    y = x
    raise y


def raise_variable_conditional():
    x = ValueError("This is a value error")
    if True:
        y = x
    else:
        y = NotImplementedError("This is a not implemented error")
    raise y


def catch_all_variables():
    try:
        raise_variable_conditional()
    except Exception as e:
        pass


def catch_one_variable():
    try:
        raise_variable_conditional()
    except ValueError as e:
        # NotImplementedError is not caught
        pass


def catch_other_variable():
    try:
        raise_variable_conditional()
    except NotImplementedError as e:
        # ValueError is not caught
        pass


def except_a_variable():
    e = Exception
    try:
        raise Exception()
    except e:
        pass
