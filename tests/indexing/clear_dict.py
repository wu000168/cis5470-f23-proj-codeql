def unsafe():
    l = {'a': 1, 'b': 2}

    l.clear()

    return l['a']
