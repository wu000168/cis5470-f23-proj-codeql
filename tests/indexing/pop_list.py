def safe():
    l = [1, 2, 3]

    l.pop()

    return l[1]


def unsafe():
    l = [1, 2, 3]

    l.pop()

    return l[2]
