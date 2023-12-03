import python

Expr resolveRaised(Expr e) {
  if e instanceof Name
  then result = e
  else
    if e instanceof Call
    then result = e
    else result = "unknown"
}

from Raise r
select r, resolveRaised(r.getException())
