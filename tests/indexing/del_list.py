def safe():
    d = [1, 2]

    del d[0]

    return d[0]


def unsafe():
    d = [1, 2]

    del d[0]

    return d[1]
