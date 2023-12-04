from __init__ import tainted_input, sanitizer, not_sanitizer

def foo():
  return tainted_input()
  
def simple1():
    return 4 / foo()  # alarm

if __name__ == '__main__':
    simple1()
