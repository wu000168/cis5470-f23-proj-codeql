def safe_1(d: dict):
    d.update({'a': 0, 'b': 1})

    return d['a'] + d['b']


def safe_2(d: dict):
    d.update({'a': 0})
    d.update({'b': 1})

    return d['a'] + d['b']


def safe_3(d: dict):
    d = {'a': 0}
    d.update({'b': 1})

    return d['a'] + d['b']


def unsafe(d: dict):
    d.update({'a': 0})

    return d['a'] + d['b']  # First is safe, second is unsafe
