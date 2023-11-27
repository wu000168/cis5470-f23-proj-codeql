def safe_1():
    l = [1, 2, 3]

    l = [x + 1 for x in l]

    return l[2]


def safe_2():
    l = [1, 2, 3]

    l = [[x] for x in l]

    return l[2]


def unsafe():
    l = [1, 2, 3]

    l = [x + 1 for x in l if False]

    return l[2]
