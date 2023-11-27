def safe():
    d = {'s': 1}

    return d['s']


def unsafe_1():
    d = {'x': 1}

    return d['y']


def unsafe_2():
    d = {'x': 1}

    del d['x']

    return d['x']
