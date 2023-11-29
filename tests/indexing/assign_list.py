def safe_1():
    l = [1, 2, 3]

    l[0] = 5


def safe_2():
    l = [1, 2, 3]

    l[-2] = 5


def unsafe_1():
    l = [1, 2]

    l[4] = 5


def unsafe_2():
    l = [1, 2]

    l[-3] = 5
