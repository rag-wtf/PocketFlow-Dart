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

  BaseNode? _cloneNode(
    BaseNode? originalNode,
    Map<BaseNode, BaseNode> clonedNodes,
  ) {
    if (originalNode == null) {
      return null;
    }
    if (clonedNodes.containsKey(originalNode)) {
      return clonedNodes[originalNode]!;
    }

    final clonedNode = originalNode.clone();
    clonedNodes[originalNode] = clonedNode;

    for (var entry in originalNode.successors.entries) {
      clonedNode.successors[entry.key] =
          _cloneNode(entry.value, clonedNodes)!;
    }

    return clonedNode;
  }

  @override
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (_start == null) {
      throw StateError('The start node has not been set.');
    }

    final clonedNodes = <BaseNode, BaseNode>{};
    final clonedStart = _cloneNode(_start, clonedNodes);

    final nodeParams =
        shared['__node_params__'] as Map<BaseNode, Map<String, dynamic>>?;
    if (nodeParams != null) {
      for (var entry in nodeParams.entries) {
        final originalNode = entry.key;
        final params = entry.value;
        if (clonedNodes.containsKey(originalNode)) {
          clonedNodes[originalNode]!.params.addAll(params);
        }
      }
    }

    var currentNode = clonedStart;
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

  @override
  Flow clone() {
    final clonedFlow = Flow();
    clonedFlow.params = Map.from(params);

    if (_start == null) {
      return clonedFlow;
    }

    final clonedNodes = <BaseNode, BaseNode>{};
    clonedFlow._start = _cloneNode(_start, clonedNodes) as Node?;

    return clonedFlow;
  }
}
