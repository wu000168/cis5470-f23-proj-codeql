/**
 * @name Indexing
 * @kind problem
 * @problem.severity warning
 * @id python/indexing
 */

import python
import semmle.python.dataflow.new.DataFlow

predicate isDict(Expr dict) {
  // A dict literal defined
  exists(Dict source | DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)))
  or
  // Argument annotated as a dict
  exists(DataFlow::ParameterNode source |
    DataFlow::localFlow(source, DataFlow::exprNode(dict)) and
    (
      source.getParameter().getAnnotation().toString() = "dict"
      or
      source.getParameter().getAnnotation().toString() = "Dict"
      or
      source.getParameter().getAnnotation().toString().prefix(4) = "dict" and
      source.getParameter().getAnnotation().toString().charAt(5) = "["
      or
      source.getParameter().getAnnotation().toString().prefix(4) = "Dict" and
      source.getParameter().getAnnotation().toString().charAt(5) = "["
    )
  )
}

predicate isDictWithKey(Expr dict, Expr key) {
  // A dict literal defined with the exact key
  exists(Dict source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)) and
    source.getAKey().(Str).getS() = key.(Str).getS()
  )
  or
  // A dict was assigned a value for the key
  exists(AssignStmt source |
    DataFlow::localFlow(DataFlow::exprNode(source.getATarget().(Subscript).getValue()),
      DataFlow::exprNode(dict)) and
    source.getATarget().(Subscript).getIndex().(Str).getS() = key.(Str).getS() and
    source.getATarget().(Subscript).getValue() != dict
  )
}

predicate isListWithIndex(Expr e, int index) {
  // A list literal defined long enough
  exists(List source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(e)) and
    exists(Expr elem | source.getElt(index) = elem)
  )
}

from Subscript sink, string msg
where
  isDictWithKey(sink.getValue(), sink.getIndex()) and
  msg = "This is a safe dictionary access of '" + sink.getIndex().(Str).getS() + "'"
  or
  isListWithIndex(sink.getValue(), sink.getIndex().(IntegerLiteral).getValue()) and
  msg = "This is a safe list access of '" + sink.getIndex().(IntegerLiteral).getValue() + "'"
  or
  // Allow assigning to a dict
  exists(AssignStmt asgn |
    asgn.getATarget().(Subscript).getValue() = sink.getValue() and isDict(sink.getValue())
  ) and
  msg = "This is a safe indexed assignment"
select sink, msg
