def safe():
    d = {'a': 1, 'b': 0}

    d.pop('b')

    return d['a']


def unsafe():
    d = {'a': 1}

    d.pop('a')

    return d['a']
