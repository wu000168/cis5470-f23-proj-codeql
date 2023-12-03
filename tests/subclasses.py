def catch_super():
    try:
        raise ValueError("This is a value error")
    except Exception as e:
        pass


def catch_exact():
    try:
        raise ValueError("This is a value error")
    except ValueError as e:
        pass


def catch_sub():
    try:
        raise Exception("This is an exception")
    except ValueError as e:
        pass


def catch_unrelated():
    try:
        raise ValueError("This is a value error")
    except TypeError as e:
        pass


class CustomException(Exception):
    pass


def raise_custom():
    raise CustomException("This is a custom exception")
