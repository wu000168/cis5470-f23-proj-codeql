def safe_1(x: bool):
    if x:
        d = {'a': 'b', 'k': 'l'}
    else:
        d = {'c': 'o', 'a': 'h'}

    return d['a']


def safe_2(x: bool):
    if x:
        l = [1]
    else:
        l = [7, 'k']

    return l[-1]


def unsafe_1(x: bool):
    if x:
        d = {'a': 'b', 'k': 'l'}
    else:
        d = {'c': 'o', }

    return d['a']


def unsafe_2(x: bool):
    if x:
        l = [1]
    else:
        l = [7, 'k']

    return l[-2]
