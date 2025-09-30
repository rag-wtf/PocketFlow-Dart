import 'dart:async';

import 'package:pocketflow/src/async_batch_flow.dart';

/// An asynchronous parallel batch flow that runs the flow multiple times in
/// parallel with different parameters.
///
/// `AsyncParallelBatchFlow` extends `AsyncBatchFlow` and implements the
/// parallel batch processing pattern from Python's PocketFlow. It runs the flow
/// graph multiple times in parallel, once for each set of parameters returned
/// by `prepAsync`.
///
/// This matches Python's implementation:
/// ```python
/// class AsyncParallelBatchFlow(AsyncFlow,BatchFlow):
///     async def _run_async(self,shared):
///         pr=await self.prep_async(shared) or []
///         await asyncio.gather(
///             *(self._orch_async(shared,{**self.params,**bp}) for bp in pr)
///         )
///         return await self.post_async(shared,pr,None)
/// ```
///
/// Key differences from `AsyncBatchFlow`:
/// - `AsyncBatchFlow`: Runs the flow **sequentially** with different params
/// - `AsyncParallelBatchFlow`: Runs the flow **in parallel** with different
///   params
///
/// Example:
/// ```dart
/// class MyParallelBatchFlow extends AsyncParallelBatchFlow {
///   @override
///   Future<List<Map<String, dynamic>>> prepAsync(
///     Map<String, dynamic> shared,
///   ) async {
///     return [
///       {'id': 1},
///       {'id': 2},
///       {'id': 3},
///     ];
///   }
/// }
///
/// final flow = MyParallelBatchFlow(start: myNode);
/// await flow.runAsync(shared);
/// ```
class AsyncParallelBatchFlow extends AsyncBatchFlow {
  /// Creates a new [AsyncParallelBatchFlow].
  ///
  /// An optional [start] node can be provided to set the entry point of the
  /// flow.
  AsyncParallelBatchFlow({super.start});

  @override
  /// Async-specific run method for AsyncParallelBatchFlow.
  ///
  /// This method follows Python's AsyncParallelBatchFlow pattern:
  /// 1. Calls prepAsync(shared) to get a list of parameter maps
  /// 2. For each parameter map, calls orchAsync with merged parameters
  ///    IN PARALLEL
  /// 3. Calls postAsync(shared, prepResult, null)
  ///
  /// Matches Python's _run_async method:
  /// ```python
  /// async def _run_async(self,shared):
  ///     pr=await self.prep_async(shared) or []
  ///     await asyncio.gather(
  ///         *(self._orch_async(shared,{**self.params,**bp}) for bp in pr)
  ///     )
  ///     return await self.post_async(shared,pr,None)
  /// ```
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    // Store shared for use in lifecycle methods
    this.shared = shared;

    // Get batch parameters from prepAsync
    final prepResult = await prepAsync(shared);
    final batchParams = (prepResult as List<Map<String, dynamic>>?) ?? [];

    // Run the flow in parallel for each set of batch parameters
    // This is the key difference from AsyncBatchFlow which runs sequentially
    final futures = batchParams.map((batchParam) {
      // Merge flow params with batch params (batch params override)
      final mergedParams = <String, dynamic>{
        ...params,
        ...batchParam,
      };

      // Run orchestration with merged parameters
      // Note: orchAsync delegates to orch, which handles the node execution
      return orchAsync(shared, mergedParams);
    });

    // Wait for all parallel executions to complete
    await Future.wait(futures);

    // Return post-processing result
    return postAsync(shared, prepResult, null);
  }

  @override
  /// Creates a deep copy of this [AsyncParallelBatchFlow].
  AsyncParallelBatchFlow clone() {
    return super.copy(AsyncParallelBatchFlow.new);
  }
}
