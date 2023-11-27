def safe_1(l: list):
    '''`l` definitely has length at least 1'''

    l.extend([1])

    return l[0]


def safe_2(l: list):
    '''`l` definitely has length at least 1'''

    l = [1, 2, 3]

    l.extend([4, 5, 6])

    return l[5]


def unsafe(l: list):
    '''`l` might be empty'''

    l.extend([1])

    return l[1]
