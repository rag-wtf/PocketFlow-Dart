import 'dart:async';

import 'package:pocketflow/src/async_flow.dart';
import 'package:pocketflow/src/base_node.dart';

/// A flow that processes a batch of items sequentially through a series of
/// asynchronous nodes.
///
/// `AsyncBatchFlow` is designed for scenarios where a collection of items needs
/// to be processed in a pipeline fashion. Each node in the flow receives the
/// batch of items, performs an asynchronous operation, and passes the modified
/// batch to the next node.
class AsyncBatchFlow<TIn, TOut> extends AsyncFlow {
  /// Creates an instance of [AsyncBatchFlow].
  ///
  /// The [nodes] parameter is a list of [BaseNode] instances that make up the
  /// flow. The nodes are chained together in the order they are provided.
  AsyncBatchFlow(this.nodes) {
    if (nodes.isEmpty) {
      throw ArgumentError('The list of nodes cannot be empty.');
    }

    start(nodes.first);
    for (var i = 0; i < nodes.length - 1; i++) {
      nodes[i].next(nodes[i + 1]);
    }
  }

  /// The list of nodes in the flow.
  final List<BaseNode> nodes;

  @override
  /// Executes the asynchronous batch flow.
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
        'AsyncBatchFlow requires a list of items under the key "items" in '
        'its params.',
      );
    }

    // The initial `shared` storage is populated with the batch of items.
    // Each subsequent node in the flow is responsible for reading from and
    // writing to the 'items' key in the `shared` map.
    final initialShared = Map<String, dynamic>.from(shared);
    initialShared['items'] = List<TIn>.from(params['items'] as List);

    // The `super.run()` method executes the flow of nodes. Each node will
    // read and write to the `initialShared` map.
    return super.run(initialShared);
  }

  @override
  AsyncBatchFlow<TIn, TOut> clone() {
    final clonedNodes = nodes.map((node) => node.clone()).toList();
    return AsyncBatchFlow<TIn, TOut>(clonedNodes)
      ..name = name
      ..params = Map.from(params);
  }
}
