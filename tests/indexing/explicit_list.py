def safe_1():
    l = [1]

    return l[0]


def safe_2():
    l = [1, 2, 3, 4, 5]

    return l[3]


def safe_3():
    l = [1, 2, 3, 4, 5]

    return l[-3]


def unsafe_1():
    l = [1]

    return l[1]


def unsafe_2():
    l = []

    return l[-1]
