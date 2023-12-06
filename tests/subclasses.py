def catch_super():
    # SHOULD NOT BE in the output
    try:
        raise ValueError("This is a value error")
    except Exception as e:
        pass


def catch_exact():
    # SHOULD NOT BE in the output
    try:
        raise ValueError("This is a value error")
    except ValueError as e:
        pass


def catch_sub():
    # SHOULD BE in the output
    try:
        raise Exception("This is an exception")
    except ValueError as e:
        pass


def catch_unrelated():
    # SHOULD BE in the output
    try:
        raise ValueError("This is a value error")
    except TypeError as e:
        pass


class CustomException(Exception):
    pass


class AnotherCustomException(CustomException):
    pass


def raise_custom():
    # SHOULD BE in the output
    raise CustomException("This is a custom exception")


def catch_custom_super_exception():
    # SHOULD NOT BE in the output
    try:
        raise CustomException("This is a custom exception")
    except Exception as e:
        pass


def catch_custom_super_custom():
    # SHOULD NOT BE in the output
    try:
        raise AnotherCustomException("This is another custom exception")
    except CustomException as e:
        pass


def catch_custom_sub():
    # SHOULD BE in the output
    try:
        raise CustomException("This is a custom exception")
    except AnotherCustomException as e:
        pass


def catch_custom_unrelated():
    # SHOULD BE in the output
    try:
        raise CustomException("This is a custom exception")
    except TypeError as e:
        pass


def catch_custom_exact():
    # SHOULD NOT BE in the output
    try:
        raise CustomException("This is a custom exception")
    except CustomException as e:
        pass
