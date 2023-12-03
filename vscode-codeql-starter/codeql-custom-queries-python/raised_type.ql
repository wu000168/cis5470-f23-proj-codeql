import python

from Raise r, Function f, Call c, ClassValue cv
where
  f.contains(r) and
  c = r.getException() and
  cv = c.getFunc().pointsTo()
select f, r.getException(), cv
