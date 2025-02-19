/**
 * @name Indexing
 * @kind problem
 * @problem.severity warning
 * @id python/indexing
 */

import python
import semmle.python.dataflow.new.DataFlow

// Calls of the form `x.y(...)`
class MethodCall extends Call {
  Attribute attr;

  MethodCall() { attr = this.getFunc().(Attribute) }

  Expr getValue() { result = attr.getValue() }

  string getName() { result = attr.getName() }
}

module ListIndexConfig implements DataFlow::StateConfigSig {
  class FlowState = int;

  additional predicate isList(Expr list) {
    // A list literal defined
    exists(List source | DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(list)))
    or
    // A list comprehension
    exists(ListComp source |
      DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(list))
    )
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

  predicate isSource(DataFlow::Node source, FlowState state) {
    // A list literal defined long enough
    exists(Expr elem | source.asExpr().(List).getElt(state) = elem)
  }

  predicate isBarrierIn(DataFlow::Node node) { joinsIf(node.asCfgNode()) }

  predicate isBarrierOut(DataFlow::Node node) {
    // List was cleared
    exists(MethodCall call | node.asExpr() = call.getValue() and call.getName() = "clear")
    or
    // Popping
    exists(MethodCall call | node.asExpr() = call.getValue() and call.getName() = "pop")
    or
    // Delete
    exists(Delete del, Subscript sub |
      del.getATarget() = sub and
      sub.getValue() = node.asExpr()
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    // List was extended using one long enough
    exists(MethodCall call |
      node1.asExpr() = call.getArg(0) and
      node2.asExpr() = call.getValue() and
      isList(call.getValue()) and
      call.getName() = "extend"
    )
    or
    // List comprehension of one long enough, without a condition
    node1.asExpr() = node2.asExpr().(ListComp).getIterable() and
    not node2.asExpr().(ListComp).getNthInnerLoop(_).getAStmt() instanceof If
  }

  predicate isSink(DataFlow::Node sink, FlowState state) {
    // Subscript
    exists(Subscript sub |
      sink.asExpr() = sub.getValue() and
      (
        state = sub.getIndex().(IntegerLiteral).getValue() or
        state = -sub.getIndex().(NegativeIntegerLiteral).getValue() - 1
      )
    )
  }
}

module ListIndexFlow = DataFlow::GlobalWithState<ListIndexConfig>;

module DictKeyConfig implements DataFlow::StateConfigSig {
  class FlowState = string;

  additional FlowState exprToState(Expr e) {
    result = "\"" + e.(Str).getS() + "\"" or
    result = e.(Num).getN()
  }

  additional predicate isDict(Expr dict) {
    // A dict literal defined
    exists(Dict source | DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict)))
    or
    // A dict comprehension
    exists(DictComp source |
      DataFlow::localFlow(DataFlow::exprNode(source), DataFlow::exprNode(dict))
    )
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

  predicate isBarrierIn(DataFlow::Node node) { joinsIf(node.asCfgNode()) }

  predicate isBarrierOut(DataFlow::Node node) {
    // Dict was cleared
    exists(MethodCall call | node.asExpr() = call.getValue() and call.getName() = "clear")
  }

  predicate isBarrierOut(DataFlow::Node node, FlowState state) {
    // Deleting key
    exists(Delete del, Subscript sub |
      del.getATarget() = sub and
      sub.getValue() = node.asExpr() and
      state = exprToState(sub.getIndex())
    )
    or
    // Popping key
    exists(MethodCall call |
      node.asExpr() = call.getValue() and
      call.getName() = "pop" and
      state = exprToState(call.getArg(0))
    )
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    // Transfer flow from `node1` when used to `update` `node2`
    exists(MethodCall call |
      node1.asExpr() = call.getArg(0) and
      node2.asExpr() = call.getValue() and
      isDict(call.getValue()) and
      call.getName() = "update"
    )
    or
    // Dict comprehension of one containing key, without a condition, using the key
    exists(DictComp comp |
      node1.asExpr() = comp.getIterable() and
      node2.asExpr() = comp and
      comp.getElt().(Tuple).getElt(1).(Name).getVariable() = comp.getIterationVariable(0) and
      not comp.getNthInnerLoop(_).getAStmt() instanceof If
    )
    or
    // Dict comprehension of `items()` of one containing key, without a condition, using the key
    exists(DictComp comp |
      node1.asExpr() = comp.getIterable().(MethodCall).getValue() and
      node2.asExpr() = comp and
      comp.getIterable().(MethodCall).getName() = "items" and
      comp.getElt().(Tuple).getElt(1).(Name).getVariable() =
        comp.getNthInnerLoop(_).getTarget().(Tuple).getElt(0).(Name).getVariable() and
      not comp.getNthInnerLoop(_).getAStmt() instanceof If
    )
    or
    // Dict comprehension of `keys()` of one containing key, without a condition, using the key
    exists(DictComp comp |
      node1.asExpr() = comp.getIterable().(MethodCall).getValue() and
      node2.asExpr() = comp and
      comp.getIterable().(MethodCall).getName() = "keys" and
      comp.getElt().(Tuple).getElt(1).(Name).getVariable() = comp.getIterationVariable(0) and
      not comp.getNthInnerLoop(_).getAStmt() instanceof If
    )
  }

  predicate isSink(DataFlow::Node sink, FlowState state) {
    // Subscript which isn't an assignment
    exists(Subscript sub |
      sink.asExpr() = sub.getValue() and
      not exists(AssignStmt asgn | asgn.getATarget() = sub) and
      (state = "\"" + sub.getIndex().(Str).getS() + "\"" or state = sub.getIndex().(Num).getN())
    )
  }
}

module DictKeyFlow = DataFlow::GlobalWithState<DictKeyConfig>;

// Get the appropriate message for a given Subscript
string getSubscriptMsg(Subscript sub) {
  ListIndexConfig::isList(sub.getValue()) and
  (
    if
      exists(DataFlow::Node source |
        ListIndexFlow::flow(source, DataFlow::exprNode(sub.getValue()))
      )
    then (
      if exists(AssignStmt asgn | asgn.getATarget() = sub)
      then (
        result =
          "This is a safe list assignment at index " + sub.getIndex().(IntegerLiteral).getValue() or
        result =
          "This is a safe list assignment at index " +
            sub.getIndex().(NegativeIntegerLiteral).getValue()
      ) else (
        result = "This is a safe list access at index " + sub.getIndex().(IntegerLiteral).getValue() or
        result =
          "This is a safe list access at index " +
            sub.getIndex().(NegativeIntegerLiteral).getValue()
      )
    ) else (
      if exists(AssignStmt asgn | asgn.getATarget() = sub)
      then (
        result =
          "This is a potentially unsafe list assignment at index " +
            sub.getIndex().(IntegerLiteral).getValue() or
        result =
          "This is a potentially unsafe list assignment at index " +
            sub.getIndex().(NegativeIntegerLiteral).getValue()
      ) else (
        result =
          "This is a potentially unsafe list access at index " +
            sub.getIndex().(IntegerLiteral).getValue() or
        result =
          "This is a potentially unsafe list access at index " +
            sub.getIndex().(NegativeIntegerLiteral).getValue()
      )
    )
  )
  or
  DictKeyConfig::isDict(sub.getValue()) and
  not exists(AssignStmt asgn | asgn.getATarget() = sub) and
  (
    if exists(DataFlow::Node source | DictKeyFlow::flow(source, DataFlow::exprNode(sub.getValue())))
    then
      result = "This is a safe dictionary access of " + DictKeyConfig::exprToState(sub.getIndex())
    else
      result =
        "This is a potentially unsafe dictionary access of " +
          DictKeyConfig::exprToState(sub.getIndex())
  )
}

// Is true if the statement is inside of an if block
predicate stmtIsInIf(Stmt stmt) { exists(If i | (stmt = i.getAStmt() or stmt = i.getAnOrelse())) }

// Is true if the statement is the first statement outside of an if block
predicate joinsIf(ControlFlowNode node) {
  stmtIsInIf(fromCF(node.getAPredecessor())) and
  not stmtIsInIf(fromCF(node))
}

// Get potential If joins
Stmt fromCF(ControlFlowNode node) {
  result.getAChildNode() = node.getNode() and not result instanceof If
}

from Subscript sink, string msg
where msg = getSubscriptMsg(sink)
select sink, msg
