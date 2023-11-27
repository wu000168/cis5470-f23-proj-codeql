def safe_1():
    l = []

    l.push(1)

    return l[0]


def safe_2():
    l = [1]

    l.push(3)

    return l[1]


def unsafe():
    l = []

    l.push(5)

    return l[1]
