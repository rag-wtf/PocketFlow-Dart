import 'dart:async';

import 'package:pocketflow/src/base_node.dart';
import 'package:pocketflow/src/node.dart';

/// A [Flow] is a specialized [BaseNode] that orchestrates the execution of a
/// graph of nodes. It manages the flow of data and control between nodes.
class Flow extends BaseNode {
  /// Creates a new [Flow].
  ///
  /// An optional [start] node can be provided to set the entry point of the
  /// flow.
  Flow({Node? start}) : _start = start;

  Node? _start;

  /// Sets the starting [node] for the flow.
  ///
  /// Returns the [node] that was set as the start node.
  Node start(Node node) {
    _start = node;
    return node;
  }

  @override
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (_start == null) {
      throw StateError('The start node has not been set.');
    }

    BaseNode? currentNode = _start;
    dynamic lastResult;

    while (currentNode != null) {
      lastResult = await currentNode.run(shared);

      if (lastResult is String &&
          currentNode.successors.containsKey(lastResult)) {
        currentNode = currentNode.successors[lastResult];
      } else if (currentNode.successors.containsKey('default')) {
        currentNode = currentNode.successors['default'];
      } else {
        currentNode = null;
      }
    }

    return lastResult;
  }
}
