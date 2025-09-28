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
  /// Runs the flow for a batch of inputs.
  ///
  /// This method overrides the parent [Flow.run] method. It expects the
  /// `shared` map to contain a list of inputs under the key `'items'`.
  ///
  /// It iterates over the inputs, and for each one, it executes the entire
  /// flow by calling `super.run()`. This ensures that each execution is
  /// isolated, as the parent `run` method handles the cloning of nodes.
  ///
  /// Returns a list of outputs corresponding to each input.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (!shared.containsKey('items') || shared['items'] is! List) {
      throw ArgumentError(
        'BatchFlow requires a list of items under the key "items".',
      );
    }
    final inputs = List<I>.from(shared['items'] as List);
    final outputs = <O>[];

    for (final input in inputs) {
      final singleInputShared = {'value': input};
      final result = await super.run(singleInputShared);
      outputs.add(result as O);
    }

    return outputs;
  }

  @override
  /// Creates a deep copy of this [BatchFlow].
  BatchFlow<I, O> clone() {
    final clonedNodes = _nodes.map((node) => node.clone()).toList();
    return BatchFlow<I, O>(clonedNodes);
  }
}
