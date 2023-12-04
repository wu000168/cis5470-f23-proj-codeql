def tainted_input() -> int:
    return 0

def untainted_input() -> int:
    return 1

def sanitizer(inp : int) -> int:
    if inp == 0:
        return 1
    else:
        return inp

def not_sanitizer(inp : int) -> int:
    return inp
