import 'dart:async';

import 'package:pocketflow/src/async_flow.dart';
import 'package:pocketflow/src/base_node.dart';

/// A class for orchestrating parallel, asynchronous batch flows.
class AsyncParallelBatchFlow<TIn, TOut> extends AsyncFlow {
  /// Creates an instance of [AsyncParallelBatchFlow].
  ///
  /// The [nodes] parameter is a list of [BaseNode] instances that will be
  /// executed in parallel for each item in the batch.
  AsyncParallelBatchFlow(this.nodes) {
    if (nodes.isEmpty) {
      throw ArgumentError('The list of nodes cannot be empty.');
    }
  }

  /// The list of nodes to be executed in parallel for each item.
  final List<BaseNode> nodes;

  /// Executes the flow with a given list of [items].
  Future<dynamic> call(List<TIn> items) async {
    return run({'input': items});
  }

  @override
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (!shared.containsKey('input') || shared['input'] is! List) {
      throw ArgumentError(
        'AsyncParallelBatchFlow requires a list of items under the key '
        '"input" in the shared context. Use the call() method to provide the '
        'input list.',
      );
    }

    final items = List<TIn>.from(shared['input'] as List);

    final batchFutures = items.map((item) {
      final nodeFutures = nodes.map((node) {
        final clonedNode = node.clone();
        // Each node runs with the same item from the batch as input.
        return clonedNode.run({'input': item});
      });
      return Future.wait(nodeFutures);
    });

    return Future.wait(batchFutures);
  }

  @override
  AsyncParallelBatchFlow<TIn, TOut> clone() {
    final clonedNodes = nodes.map((node) => node.clone()).toList();
    return AsyncParallelBatchFlow<TIn, TOut>(clonedNodes);
  }
}
