import python

from Raise r, Function f, Call c, Value v
where
  f.contains(r) and
  c = r.getException() and
  v = c.getFunc().pointsTo()
select f, r.getException(), v
