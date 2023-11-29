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

module DictIndexConfig implements DataFlow::StateConfigSig {
  class FlowState = string;

  additional FlowState exprToState(Expr e) {
    result = "\"" + e.(Str).getS() + "\"" or
    result = e.(Num).getN()
  }

  predicate isSource(DataFlow::Node source, FlowState state) {
    // Dictionary literal
    state = exprToState(source.asExpr().(Dict).getAKey())
    or
    // Assignment to dictionary
    isDict(source.asExpr()) and
    exists(AssignStmt asgn, Subscript sub |
      asgn.getATarget() = sub and
      sub.getValue() = source.asExpr() and
      state = exprToState(sub.getIndex())
    )
  }

  predicate isBarrierOut(DataFlow::Node node, FlowState state) {
    // Deleting key
    exists(Delete del, Subscript sub |
      del.getATarget() = sub and
      sub.getValue() = node.asExpr() and
      state = exprToState(sub.getIndex())
    )
  }

  predicate isAdditionalFlowStep(
    DataFlow::Node node1, FlowState state1, DataFlow::Node node2, FlowState state2
  ) {
    none()
  }

  predicate isSink(DataFlow::Node sink, FlowState state) {
    exists(Subscript sub |
      sink.asExpr() = sub.getValue() and
      not exists(AssignStmt asgn | asgn.getATarget() = sub) and
      (state = "\"" + sub.getIndex().(Str).getS() + "\"" or state = sub.getIndex().(Num).getN())
    )
  }
}

module DictIndexFlow = DataFlow::GlobalWithState<DictIndexConfig>;

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
      source.getParameter().getAnnotation().toString().charAt(4) = "["
      or
      source.getParameter().getAnnotation().toString().prefix(4) = "Dict" and
      source.getParameter().getAnnotation().toString().charAt(4) = "["
    )
  )
}

predicate isDictWithKey(Expr dict, string key) {
  // A dict literal defined with the exact key
  exists(Dict source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)) and
    (
      key = source.getAKey().(Str).getS() or
      key = source.getAKey().(Num).getN()
    )
  )
  or
  // Dict was assigned a value for the key
  exists(AssignStmt source |
    DataFlow::localFlow(DataFlow::exprNode(source.getATarget().(Subscript).getValue()),
      DataFlow::exprNode(dict)) and
    (
      key = source.getATarget().(Subscript).getIndex().(Str).getS() or
      key = source.getATarget().(Subscript).getIndex().(Num).getN()
    ) and
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
  or
  // Dict comprehension of one containing key, without a condition, using the key
  exists(DictComp source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)) and
    isDictWithKey(source.getIterable(), key) and
    source.getElt().(Tuple).getElt(1).(Name).getVariable() = source.getIterationVariable(0) and
    not source.getNthInnerLoop(_).getAStmt() instanceof If
  )
  or
  // Dict comprehension of `items()` of one containing key, without a condition, using the key
  exists(DictComp source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)) and
    source.getIterable().(MethodCall).getName() = "items" and
    isDictWithKey(source.getIterable().(MethodCall).getValue(), key) and
    source.getElt().(Tuple).getElt(1).(Name).getVariable() =
      source.getNthInnerLoop(_).getTarget().(Tuple).getElt(0).(Name).getVariable() and
    not source.getNthInnerLoop(_).getAStmt() instanceof If
  )
  or
  // Dict comprehension of `keys()` of one containing key, without a condition, using the key
  exists(DictComp source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)) and
    source.getIterable().(MethodCall).getName() = "keys" and
    isDictWithKey(source.getIterable().(MethodCall).getValue(), key) and
    source.getElt().(Tuple).getElt(1).(Name).getVariable() = source.getIterationVariable(0) and
    not source.getNthInnerLoop(_).getAStmt() instanceof If
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
  or
  // List comprehension of one long enough, without a condition
  exists(ListComp source |
    DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(list)) and
    isListWithIndex(source.getIterable(), index) and
    not source.getNthInnerLoop(_).getAStmt() instanceof If
  )
}

string getSubscriptMsg(Subscript sink) {
  // Allow assigning to a dict
  exists(AssignStmt asgn |
    asgn.getATarget().(Subscript).getValue() = sink.getValue() and isDict(sink.getValue())
  ) and
  result = "This is a safe indexed assignment to a dict"
  or
  // Allow assigning to a list
  isListWithIndex(sink.getValue(), sink.getIndex().(IntegerLiteral).getValue()) and
  (
    if exists(AssignStmt asgn | asgn.getATarget() = sink)
    then result = "This is a safe indexed assignment to a list"
    else
      result = "This is a safe list access of '" + sink.getIndex().(IntegerLiteral).getValue() + "'"
  )
  or
  (
    isDictWithKey(sink.getValue(), sink.getIndex().(Str).getS()) or
    isDictWithKey(sink.getValue(), sink.getIndex().(Num).getN())
  ) and
  result = "This is a safe dictionary access of '" + sink.getIndex().(Str).getS() + "'"
}

// from Subscript sink, string msg
// where msg = getSubscriptMsg(sink)
// select sink, msg
// from DataFlow::Node source, DataFlow::FlowState state
// where DictIndexConfig::isSink(source, state)
// select source, state.toString()
from DataFlow::Node source, Subscript sink
where DictIndexFlow::flow(source, DataFlow::exprNode(sink.getValue()))
select sink, sink.toString()
