def safe_1():
    l = [1]

    return l[0]


def safe_2():
    l = [1, 2, 3, 4, 5]

    return l[3]


def unsafe():
    l = [1]

    return l[1]
