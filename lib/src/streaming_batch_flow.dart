import 'dart:async';

import 'package:pocketflow/src/async_flow.dart';
import 'package:pocketflow/src/base_node.dart';

/// A flow that processes a batch of items sequentially through a series of
/// nodes.
///
/// `StreamingBatchFlow` is designed for scenarios where a collection of items
/// needs to be processed in a pipeline fashion. Each node in the flow receives
/// the batch of items, performs an operation, and passes the modified batch to
/// the next node.
///
/// The flow is asynchronous, leveraging Dart's `Future` to handle operations
/// that may not complete immediately.
class StreamingBatchFlow<TIn, TOut> extends AsyncFlow {
  /// Creates an instance of [StreamingBatchFlow].
  ///
  /// The [nodes] parameter is a list of [BaseNode] instances that make up the
  /// flow. The nodes are chained together in the order they are provided.
  StreamingBatchFlow(this.nodes) {
    if (nodes.isEmpty) {
      throw StateError('The list of nodes cannot be empty.');
    }

    start(nodes.first);
    for (var i = 0; i < nodes.length - 1; i++) {
      nodes[i].next(nodes[i + 1]);
    }
  }

  /// The list of nodes in the flow.
  final List<BaseNode> nodes;

  @override
  StreamingBatchFlow<TIn, TOut> clone() {
    final clonedNodes = nodes.map((node) => node.clone()).toList();
    return StreamingBatchFlow<TIn, TOut>(clonedNodes)
      ..name = name
      ..params = Map.from(params);
  }

  @override
  /// Executes the streaming batch flow.
  ///
  /// This method expects a list of items to be provided in the flow's
  /// parameters under the key "items". It then populates the shared state with
  /// this list and executes the flow of nodes.
  ///
  /// Returns the result of the last node in the flow, which is expected to be
  /// the final processed batch of items.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    // Before the flow starts, the initial batch of items is expected to be in
    // the 'items' parameter of the flow itself.
    if (!params.containsKey('items') || params['items'] is! List) {
      throw ArgumentError(
        'StreamingBatchFlow requires a list of items under the key "items" in '
        'its params.',
      );
    }

    // The initial `shared` storage is populated with the batch of items.
    // Each subsequent node in the flow is responsible for reading from and
    // writing to the 'items' key in the `shared` map.
    final initialShared = Map<String, dynamic>.from(shared);
    initialShared['items'] = List<TIn>.from(params['items'] as List);

    // Remove 'items' from flow params so it doesn't override shared['items']
    // in subsequent nodes. Each node should read from shared['items'] which
    // gets updated by the previous node.
    final originalItems = params.remove('items');

    try {
      // The `super.run()` method executes the flow of nodes. Each node will
      // read and write to the `initialShared` map.
      return await super.run(initialShared);
    } finally {
      // Restore the items param
      params['items'] = originalItems;
    }
  }
}
