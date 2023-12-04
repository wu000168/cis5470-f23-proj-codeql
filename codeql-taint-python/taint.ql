/**
 * @kind problem
 * @problem.severity warning
 * @precision high
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.ApiGraphs

/**
 * Configuration for the global taint tracking analysis
 * also contains a general implementation of
 * local taint tracking (private & additional predicates)
 * using the same configuration (isSource, isSink, isBarrier, etc.)
 * which can be replaced for any other specific needs
 * since the built-in dataflow library is not very precise around conditionals
 */
module SimpleTaint implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asCfgNode().isCall() and
    source.(DataFlow::CallCfgNode).asCfgNode().(CallNode).getNode().getFunc().(Name).getId() =
      "tainted_input"
    // or
    // source.asExpr().(IntegerLiteral).getValue() = 0
  }

  private predicate isDiv(BinaryExpr binExpr, Expr divisor) {
    binExpr.getOp().getSpecialMethodName() in ["__truediv__", "__div__", "__floordiv__"] and
    binExpr.getRight() = divisor
  }

  predicate isSink(DataFlow::Node sink) {
    isDiv(sink.asExpr().getParent().(BinaryExpr), sink.asExpr())
  }

  predicate isBarrierOut(DataFlow::Node node) {
    node.asCfgNode().isCall() and
    node.(DataFlow::CallCfgNode).asCfgNode().(CallNode).getNode().getFunc().(Name).getId() =
      "sanitizer"
  }

  private predicate localFlowStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    DataFlow::localFlowStep(nodeFrom, nodeTo) or
    nodeTo.asExpr().(Call).getAnArg() = nodeFrom.asExpr()
  }

  private predicate localTaintStep(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    not isBarrierOut(nodeFrom) and
    localFlowStep(nodeFrom, nodeTo) and
    not isBarrierIn(nodeTo)
  }

  additional predicate localTaintFlow(DataFlow::Node nodeFrom, DataFlow::Node nodeTo) {
    isSource(nodeFrom) and
    localTaintStep(nodeFrom, nodeTo)
    or
    exists(DataFlow::Node nodeVia |
      localTaintFlow(nodeFrom, nodeVia) and
      not isBarrier(nodeVia) and
      localTaintStep(nodeVia, nodeTo)
    )
  }

  additional predicate localTaint(DataFlow::Node source, DataFlow::Node sink) {
    localTaintFlow(source, sink) and
    isSink(sink)
  }
}

/**
 * builds global analysis module with the built-in library from above configuration
 */
module SimpleTaintFlowGlobal = TaintTracking::Global<SimpleTaint>;

import SimpleTaintFlowGlobal::PathGraph

from DataFlow::Node nodeFrom, DataFlow::Node nodeTo, string kind
where
  (
    exists(SimpleTaintFlowGlobal::PathNode src |
      exists(SimpleTaintFlowGlobal::PathNode snk |
        SimpleTaintFlowGlobal::flowPath(src, snk) and
        src.getNode() = nodeFrom and
        snk.getNode() = nodeTo
      )
    ) and
    kind = "global"
    or
    SimpleTaint::localTaint(nodeFrom, nodeTo) and kind = "local"
  ) and
  kind in ["local", "global"] // adjust this to only show one analysis
select nodeTo.asExpr() as sink, "There is tainted input from $@ found by " + kind + " analysis",
  nodeFrom.asExpr() as source, nodeFrom.asExpr().toString()
