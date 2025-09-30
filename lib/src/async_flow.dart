import 'package:pocketflow/src/flow.dart';

/// A class for orchestrating flows with `async` nodes.
///
/// This class extends Flow and implements AsyncNode lifecycle methods,
/// matching Python's multiple inheritance pattern:
/// ```python
/// class AsyncFlow(Flow,AsyncNode):
///     async def _orch_async(self,shared,params=None): ...
///     async def _run_async(self,shared): ...
/// ```
///
/// Key features:
/// - Implements AsyncNode lifecycle methods (prepAsync, execAsync, postAsync)
/// - Has orchAsync method for async orchestration
/// - Handles both sync and async nodes in the flow graph
/// - Follows Python's _run_async pattern
class AsyncFlow extends Flow {
  /// Creates a new [AsyncFlow].
  ///
  /// An optional [start] node can be provided to set the entry point of the
  /// flow.
  AsyncFlow({super.start});

  // AsyncNode lifecycle methods

  /// Async pre-processing logic before orchAsync.
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return null;
  }

  /// Async execution logic - calls orchAsync.
  ///
  /// This method implements Python's AsyncFlow pattern where execAsync
  /// calls _orch_async.
  Future<dynamic> execAsync(dynamic prepResult) async {
    return orchAsync(shared);
  }

  /// Async fallback logic when execAsync fails.
  Future<dynamic> execFallbackAsync(
    dynamic prepResult,
    Exception error,
  ) async {
    return null;
  }

  /// Async post-processing logic after execAsync.
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    return execResult;
  }

  /// Async orchestration method that executes the flow graph.
  ///
  /// This method implements Python's _orch_async pattern:
  /// 1. Clone the start node
  /// 2. Set parameters (merged with flow params)
  /// 3. Execute nodes in sequence, handling both sync and async nodes
  /// 4. Return the last action/result
  ///
  /// Matches Python's implementation:
  /// ```python
  /// async def _orch_async(self,shared,params=None):
  ///     curr,p,last_action =copy.copy(self.start_node),
  ///                         (params or {**self.params}),None
  ///     while curr:
  ///         curr.set_params(p)
  ///         last_action=await curr._run_async(shared)
  ///                     if isinstance(curr,AsyncNode) else curr._run(shared)
  ///         curr=copy.copy(self.get_next_node(curr,last_action))
  ///     return last_action
  /// ```
  /// Async orchestration method that executes the flow graph.
  ///
  /// This method implements Python's _orch_async pattern by delegating
  /// to the base Flow.orch method, which already handles async nodes properly.
  ///
  /// The base Flow.orch method awaits curr.run(shared) which works for both
  /// sync and async nodes, so we don't need special handling here.
  Future<dynamic> orchAsync(
    Map<String, dynamic> shared, [
    Map<String, dynamic>? params,
    int? maxSteps,
  ]) async {
    return orch(shared, params, maxSteps);
  }

  /// Async-specific run method for AsyncFlow.
  ///
  /// This method follows Python's AsyncFlow pattern:
  /// 1. Calls prepAsync(shared) to prepare
  /// 2. Calls execAsync(prepResult) which calls orchAsync(shared)
  /// 3. Calls postAsync(shared, prepResult, execResult)
  ///
  /// Matches Python's _run_async method:
  /// ```python
  /// async def _run_async(self,shared):
  ///     p=await self.prep_async(shared); o=await self._orch_async(shared)
  ///     return await self.post_async(shared,p,o)
  /// ```
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    // Store shared for use in execAsync method
    this.shared = shared;

    // Follow the AsyncNode lifecycle: prepAsync -> execAsync -> postAsync
    final prepResult = await prepAsync(shared);
    final execResult = await execAsync(prepResult);
    return postAsync(shared, prepResult, execResult);
  }

  @override
  /// Creates a deep copy of this [AsyncFlow].
  AsyncFlow clone() {
    return super.copy(AsyncFlow.new);
  }
}
