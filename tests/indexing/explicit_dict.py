def safe_1():
    d = {'s': 1}

    return d['s']


def safe_2():
    d = {1: 2}

    return d[1]


def unsafe():
    d = {'x': 1}

    return d['y']
