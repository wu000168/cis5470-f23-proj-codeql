import python

// from Raise r, Function f, Call c, ClassValue cv
// where
//   f.contains(r) and
//   c = r.getException() and
//   cv = c.getFunc().pointsTo()
// select f, r.getException(), cv
//
// from Raise r, Function f
// where
//   f.contains(r) and
//   not exists(Call c | c = r.getException() | exists(ClassValue cv | cv = c.getFunc().pointsTo()))
// select f, r.getException()
from Raise r, Function f, Value v, Call vc, ClassValue cvvc
where
  f.contains(r) and
  not exists(Call c | c = r.getException() | exists(ClassValue cv | cv = c.getFunc().pointsTo())) and
  v = r.getException().pointsTo() and
  vc.pointsTo() = v and
  cvvc = vc.getFunc().pointsTo()
select f, r.getException(), v, vc, cvvc
