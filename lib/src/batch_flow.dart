import 'dart:async';

import 'package:pocketflow/src/flow.dart';
import 'package:pocketflow/src/node.dart';

/// A [BatchFlow] is a specialized [Flow] that processes a batch of inputs.
///
/// It orchestrates a series of nodes to be executed sequentially for each
/// input in a provided list.
class BatchFlow<I, O> extends Flow {
  /// Creates a new [BatchFlow] with a list of [nodes].
  ///
  /// The [nodes] are chained together in the order they are provided.
  BatchFlow(List<Node> nodes) : _nodes = nodes {
    if (nodes.isEmpty) {
      throw ArgumentError('The list of nodes cannot be empty.');
    }

    // Set the start node of the flow
    start(nodes.first);

    // Chain the rest of the nodes sequentially
    for (var i = 0; i < nodes.length - 1; i++) {
      nodes[i].next(nodes[i + 1]);
    }
  }

  /// The list of nodes that make up the flow.
  final List<Node> _nodes;

  @override
  /// Prepares batch parameters for processing.
  ///
  /// This method extracts items from the shared storage and converts them
  /// into a list of parameter maps. Each item becomes a parameter map with
  /// a 'value' key.
  ///
  /// This follows Python's pattern where prep() returns a list of parameter
  /// maps that will be used for batch processing.
  Future<List<Map<String, dynamic>>> prep(Map<String, dynamic> shared) async {
    if (!shared.containsKey('items') || shared['items'] is! List) {
      throw ArgumentError(
        'BatchFlow requires a list of items under the key "items".',
      );
    }

    final items = shared['items'] as List;
    return items
        .map((item) => {'value': item})
        .toList()
        .cast<Map<String, dynamic>>();
  }

  @override
  /// Runs the flow for a batch of inputs.
  ///
  /// This method follows Python's BatchFlow orchestration pattern exactly:
  /// 1. Calls prep(shared) to get batch parameters
  /// 2. For each batch parameter, calls orch with merged parameters
  /// 3. Returns post(shared, prepResult, null) - no per-item exec result
  ///    collection
  ///
  /// Matches Python's implementation:
  /// ```python
  /// def _run(self,shared):
  ///     pr=self.prep(shared) or []
  ///     for bp in pr: self._orch(shared,{**self.params,**bp})
  ///     return self.post(shared,pr,None)
  /// ```
  Future<dynamic> run(Map<String, dynamic> shared) async {
    // prep should return List<Map<String, dynamic>> (batch param maps)
    final prepResult = await prep(shared);

    for (final batchParams in prepResult) {
      final mergedParams = <String, dynamic>{};
      if (params.isNotEmpty) mergedParams.addAll(params);
      mergedParams.addAll(batchParams);

      // Temporarily set batch item value in shared for node access
      shared['value'] = batchParams['value'];

      // orch should accept params override for this batch item
      await orch(shared, mergedParams);

      // Note: Don't restore original value - let the last processed value
      // remain
    }

    // Python BatchFlow._run returns post(shared, prep_res, None)
    return post(shared, prepResult, null);
  }

  @override
  /// Creates a deep copy of this [BatchFlow].
  BatchFlow<I, O> clone() {
    final clonedNodes = _nodes.map((node) => node.clone()).toList();
    return BatchFlow<I, O>(clonedNodes);
  }
}
