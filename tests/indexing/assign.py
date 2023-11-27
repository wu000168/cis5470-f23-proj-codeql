def safe_1(d: dict):
    d['a'] = 1


def safe_2():
    d = {'c': 0}

    d['a'] = 1


def safe_3():
    d = {}

    d['a'] = 1


def unsafe(d):
    d['a'] = 1
