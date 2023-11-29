def unsafe():
    d = {'a': 1}

    d.pop('a')

    return d['a']
