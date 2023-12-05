import python

from Raise r, Function f
where
  // A raise is uncaught in a function if...
  f.contains(r) and
  // it is actually in that function (not in a nested function)...
  not exists(Function subf | f.contains(subf) and subf.contains(r)) and
  // there is no try block wrapping it...
  not exists(Try t |
    f.contains(t) and
    t.contains(r) and
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
select f, r
