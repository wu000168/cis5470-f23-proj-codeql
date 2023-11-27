/**
 * @name Indexing
 * @kind problem
 * @problem.severity warning
 * @id python/indexing
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow

class MethodCall extends Call {
  Attribute attr;

  MethodCall() { attr = this.getFunc().(Attribute) }

  Expr getValue() { result = attr.getValue() }

  string getName() { result = attr.getName() }
}

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
  // Dict was assigned a value for the key
  exists(AssignStmt source |
    DataFlow::localFlow(DataFlow::exprNode(source.getATarget().(Subscript).getValue()),
      DataFlow::exprNode(dict)) and
    source.getATarget().(Subscript).getIndex().(Str).getS() = key.(Str).getS() and
    source.getATarget().(Subscript).getValue() != dict
  )
  or
  // Dict was updated using one with key
  exists(MethodCall source |
    isDict(source.getValue()) and
    DataFlow::localFlow(DataFlow::exprNode(source.getValue()), DataFlow::exprNode(dict)) and
    source.getName() = "update" and
    isDictWithKey(source.getArg(0), key)
  )
}

predicate isList(Expr list) {
  // A list literal defined
  exists(List source | DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(list)))
  or
  // Argument annotated as a list
  exists(DataFlow::ParameterNode source |
    DataFlow::localFlow(source, DataFlow::exprNode(list)) and
    (
      source.getParameter().getAnnotation().toString() = "list"
      or
      source.getParameter().getAnnotation().toString() = "List"
      or
      source.getParameter().getAnnotation().toString().prefix(4) = "list" and
      source.getParameter().getAnnotation().toString().charAt(5) = "["
      or
      source.getParameter().getAnnotation().toString().prefix(4) = "List" and
      source.getParameter().getAnnotation().toString().charAt(5) = "["
    )
  )
}

predicate isListWithIndex(Expr list, int index) {
  // A list literal defined long enough
  exists(List source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(list)) and
    exists(Expr elem | source.getElt(index) = elem)
  )
  or
  // List was extended using one long enough
  exists(MethodCall source |
    isList(source.getValue()) and
    DataFlow::localFlow(DataFlow::exprNode(source.getValue()), DataFlow::exprNode(list)) and
    source.getName() = "extend" and
    isListWithIndex(source.getArg(0), index)
  )
}

string getSubscriptMsg(Subscript sink) {
  isDictWithKey(sink.getValue(), sink.getIndex()) and
  result = "This is a safe dictionary access of '" + sink.getIndex().(Str).getS() + "'"
  or
  isListWithIndex(sink.getValue(), sink.getIndex().(IntegerLiteral).getValue()) and
  result = "This is a safe list access of '" + sink.getIndex().(IntegerLiteral).getValue() + "'"
  or
  // Allow assigning to a dict
  exists(AssignStmt asgn |
    asgn.getATarget().(Subscript).getValue() = sink.getValue() and isDict(sink.getValue())
  ) and
  result = "This is a safe indexed assignment"
}

from Subscript sink, string msg
where msg = getSubscriptMsg(sink)
select sink, msg
