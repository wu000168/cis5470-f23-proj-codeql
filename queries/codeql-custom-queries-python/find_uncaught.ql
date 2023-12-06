import python

// A raise is uncaught in a function if...
predicate uncaught(Function f, AstNode astNode, Raise r) {
  // there is no try block wrapping it...
  not exists(Try t |
    f.contains(t) and
    t.contains(astNode) and
    // such that...
    exists(ExceptionHandler eh, Value v, Call c, ClassValue cv |
      // there is an except: clause...
      eh = t.getAHandler() and
      // where for the class of the raised exception...
      v = r.getException().pointsTo() and
      c.pointsTo() = v and
      cv = c.getFunc().pointsTo() and
      (
        // the except clause catches the exact type raised.
        cv = eh.getType().pointsTo()
        or
        // the except clause catches a superclass of the type raised.
        exists(ClassValue cvsuper | cvsuper = cv.getASuperType() |
          cvsuper = eh.getType().pointsTo()
        )
      )
    )
  )
}

predicate raises(Function f, Raise r) {
  // f raises r if...
  // r is raised in f...
  f.contains(r) and
  // it is actually in that function (not in a nested function)...
  not exists(Function subf | f.contains(subf) and subf.contains(r)) and
  // ... and it is not caught in f.
  uncaught(f, r, r)
}

predicate uncaughtCallsOrRaises(Function f, Raise r) {
  // f raises r directly or indirectly if...
  // it raises r directly...
  raises(f, r)
  or
  // or it contains a call to a function...
  exists(Function raisingFunction, CallableValue cv, Call c |
    f.contains(c) and
    cv = c.getFunc().pointsTo() and
    raisingFunction = cv.getScope() and
    // it does not catch the exception raised by that function...
    uncaught(f, c, r) and
    // ...and that function raises r directly or indirectly.
    uncaughtCallsOrRaises(raisingFunction, r)
  )
}

from Function f, Raise r
where uncaughtCallsOrRaises(f, r)
select f, r
