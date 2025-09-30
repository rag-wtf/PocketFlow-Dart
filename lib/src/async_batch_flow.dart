import 'dart:async';

import 'package:pocketflow/src/async_flow.dart';

/// An asynchronous batch flow that runs the flow multiple times with different
/// parameters.
///
/// `AsyncBatchFlow` extends `AsyncFlow` and implements the batch processing
/// pattern from Python's PocketFlow. It runs the flow graph multiple times,
/// once for each set of parameters returned by `prepAsync`.
///
/// This matches Python's implementation:
/// ```python
/// class AsyncBatchFlow(AsyncFlow,BatchFlow):
///     async def _run_async(self,shared):
///         pr=await self.prep_async(shared) or []
///         for bp in pr: await self._orch_async(shared,{**self.params,**bp})
///         return await self.post_async(shared,pr,None)
/// ```
///
/// Key differences from `StreamingBatchFlow`:
/// - `AsyncBatchFlow`: Runs the flow **multiple times** with different params
/// - `StreamingBatchFlow`: Processes items through a **pipeline** of nodes
class AsyncBatchFlow extends AsyncFlow {
  /// Creates a new [AsyncBatchFlow].
  ///
  /// An optional [start] node can be provided to set the entry point of the
  /// flow.
  AsyncBatchFlow({super.start});

  @override
  /// Async-specific run method for AsyncBatchFlow.
  ///
  /// This method follows Python's AsyncBatchFlow pattern:
  /// 1. Calls prepAsync(shared) to get a list of parameter maps
  /// 2. For each parameter map, calls orchAsync with merged parameters
  /// 3. Calls postAsync(shared, prepResult, null)
  ///
  /// Matches Python's _run_async method:
  /// ```python
  /// async def _run_async(self,shared):
  ///     pr=await self.prep_async(shared) or []
  ///     for bp in pr: await self._orch_async(shared,{**self.params,**bp})
  ///     return await self.post_async(shared,pr,None)
  /// ```
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    // Store shared for use in lifecycle methods
    this.shared = shared;

    // Get batch parameters from prepAsync
    final prepResult = await prepAsync(shared);
    final batchParams = (prepResult as List<Map<String, dynamic>>?) ?? [];

    // Run the flow once for each set of batch parameters
    for (final batchParam in batchParams) {
      // Merge flow params with batch params (batch params override)
      final mergedParams = <String, dynamic>{
        ...params,
        ...batchParam,
      };

      // Run orchestration with merged parameters
      // Note: orchAsync delegates to orch, which handles the node execution
      await orchAsync(shared, mergedParams);
    }

    // Return post-processing result
    return postAsync(shared, prepResult, null);
  }

  @override
  /// Creates a deep copy of this [AsyncBatchFlow].
  AsyncBatchFlow clone() {
    return super.copy(AsyncBatchFlow.new);
  }
}
