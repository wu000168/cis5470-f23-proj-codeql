def safe():
    l1 = [1, 5]

    l2 = l1.copy()

    return l2[0]


def unsafe():
    l1 = [1, 5]

    l2 = l1.copy()

    return l2[3]
