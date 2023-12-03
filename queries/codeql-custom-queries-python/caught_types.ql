import python

from Try t, ExceptionHandler eh
where t.contains(eh)
select eh, eh.getType()
