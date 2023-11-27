def safe(l: list):
    '''`l` definitely has lenght at least 1'''

    l.extend([1])

    return l[0]


def unsafe(l: list):
    '''`l` might be empty'''

    l.extend([1])

    return l[1]
