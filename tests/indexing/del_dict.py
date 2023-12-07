def safe():
    d = {'x': 1, 'y': 2}

    del d['x']

    return d['y']


def unsafe():
    d = {'x': 1}

    del d['x']

    return d['x']
