import python
import semmle.python.ApiGraphs

// from Call call, Name name
// where call.getFunc() = name and name.getId() = "Exception"
// select call
//
// Doesn't work for builtin exceptions, only newly declared ones
// select API::builtin("Exception").getASubclass().getACall()
//
// select API::builtin("Exception").getACall()
// from Class cls, Call call, CallableExpr ce
// from Call call, Name n
// where call.getFunc() = n
// //   n.pointsTo() and
// //   f = cls.getInitMethod()
// // select cls, call
// select call, n
//
// from Call call, Name n, Value v, ControlFlowNode cfn, FunctionObject f, ClassObject cls
// where
//   call.getFunc() = n and
//   n.getAFlowNode() = cfn
// select call, cfn
from ClassObject cls
select cls, cls.getABaseType(), cls.getACall()
