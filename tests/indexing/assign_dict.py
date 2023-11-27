def safe(d: dict):
    d['a'] = 5

    return d['a']


def unsafe(d: dict):
    d['x'] = 5

    return d['y']
