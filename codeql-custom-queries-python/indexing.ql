/**
 * @name Indexing
 * @kind problem
 * @problem.severity warning
 * @id python/indexing
 */

import python
import semmle.python.dataflow.new.DataFlow

from Subscript sink, string msg
where
  (
    // A dict literal defined with the exact key
    exists(Dict source |
      DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink.getValue())) and
      source.getAKey().(Str).getS() = sink.getIndex().(Str).getS()
    )
    or
    // A dict was assigned a value for the key
    exists(AssignStmt source |
      DataFlow::localFlow(DataFlow::exprNode(source.getATarget().(Subscript).getValue()),
        DataFlow::exprNode(sink.getValue())) and
      source.getATarget().(Subscript).getIndex().(Str).getS() = sink.getIndex().(Str).getS() and
      source.getATarget() != sink
    )
  ) and
  msg = "This is a safe dictionary access of '" + sink.getIndex().(Str).getS() + "'"
  or
  // A list literal defined long enough
  exists(List source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(sink.getValue())) and
    exists(Expr elem | source.getElt(sink.getIndex().(IntegerLiteral).getValue()) = elem)
  ) and
  msg = "This is a safe list access of '" + sink.getIndex().(IntegerLiteral).getValue() + "'"
  or
  // Allow assigning to a dict
  exists(DataFlow::ParameterNode source |
    exists(AssignStmt asgn |
      DataFlow::localFlow(source, DataFlow::exprNode(sink.getValue())) and
      source.getParameter().getAnnotation().toString().prefix(4) = "dict" and
      asgn.getATarget() = sink
    )
  ) and
  msg = "This is a safe indexed assignment"
select sink, msg
