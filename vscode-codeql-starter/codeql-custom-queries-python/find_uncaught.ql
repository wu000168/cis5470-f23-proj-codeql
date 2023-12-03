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
          cv = eh.getType().pointsTo()
          or
          exists(ClassValue cvsuper | cvsuper = cv.getASuperType() |
            cvsuper = eh.getType().pointsTo()
          )
        )
      )
    )
  )
select f, r.getException(), r.getException().pointsTo()
