import python

from Raise r, Function f
where
  f.contains(r) and
  not exists(Try t |
    f.contains(t) and
    t.contains(r) and
    exists(ExceptionHandler eh | eh = t.getAHandler() |
      exists(Call c | c = r.getException() |
        exists(ClassValue cv | cv = c.getFunc().pointsTo() |
          // except clause catches the exact type raised
          cv = eh.getType().pointsTo()
          or
          // except clause catches a superclass of the type raised
          exists(ClassValue cvsuper | cvsuper = cv.getASuperType() |
            cvsuper = eh.getType().pointsTo()
          )
        )
      )
      or
      exists(Value v | v = r.getException().pointsTo() |
        exists(Call c | c.pointsTo() = v |
          exists(ClassValue cv | cv = c.getFunc().pointsTo() |
            // except clause catches the exact type raised
            cv = eh.getType().pointsTo()
            or
            // except clause catches a superclass of the type raised
            exists(ClassValue cvsuper | cvsuper = cv.getASuperType() |
              cvsuper = eh.getType().pointsTo()
            )
          )
        )
      )
    )
  )
select f, r.getException(), r.getException().pointsTo()
