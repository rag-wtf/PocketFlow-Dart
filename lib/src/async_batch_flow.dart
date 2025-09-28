import 'dart:async';

import 'package:pocketflow/src/async_flow.dart';
import 'package:pocketflow/src/base_node.dart';

/// A class for orchestrating asynchronous batch flows.
class AsyncBatchFlow<TIn, TOut> extends AsyncFlow {
  /// Creates an instance of [AsyncBatchFlow].
  ///
  /// The [nodes] parameter is a list of [BaseNode] instances that make up the
  /// flow.
  AsyncBatchFlow(List<BaseNode> nodes) {
    if (nodes.isEmpty) {
      throw ArgumentError('The list of nodes cannot be empty.');
    }

    start(nodes.first);
    for (var i = 0; i < nodes.length - 1; i++) {
      nodes[i].next(nodes[i + 1]);
    }
  }

  @override
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
}
