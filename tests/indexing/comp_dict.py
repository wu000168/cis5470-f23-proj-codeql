def safe_1():
    d = {'a': 1, 'b': 2}

    d = {k: 10 for k in d}

    return d['a']


def safe_2():
    d = {'a': 1, 'b': 2}

    d = {k: v for k, v in d.items()}

    return d['a']


def safe_3():
    d = {'a': 1, 'b': 2}

    d = {k: 0 for k in d.keys()}

    return d['a']


def unsafe():
    d = {'a': 1, 'b': 2}

    d = {k: v for k, v in d.items() if False}

    return d['a']
