def safe_1():
    l = [1, 2, 3]

    l[0] = 5


def unsafe():
    l = [1, 2]

    l[4] = 5
