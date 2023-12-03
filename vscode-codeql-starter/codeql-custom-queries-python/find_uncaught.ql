import python

from Raise r, Function f
where
  f.contains(r) and
  not exists(Try t |
    f.contains(t) and
    t.contains(r) and
    exists(ExceptionHandler eh | eh = t.getAHandler() |
      exists(Call c | c = r.getException() | c.getFunc().pointsTo() = eh.getType().pointsTo())
    )
  )
select f, r.getException(), r.getException().pointsTo()
