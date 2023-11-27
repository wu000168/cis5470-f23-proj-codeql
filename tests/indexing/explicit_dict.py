def safe():
    d = {'s': 1}

    return d['s']


def unsafe():
    d = {'x': 1}

    return d['y']
