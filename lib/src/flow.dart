import 'dart:async';

import 'package:pocketflow/src/base_node.dart';

/// A [Flow] is a specialized [BaseNode] that orchestrates the execution of a
/// graph of nodes. It manages the flow of data and control between nodes.
class Flow extends BaseNode {
  /// Creates a new [Flow].
  ///
  /// An optional [start] node can be provided to set the entry point of the
  /// flow.
  Flow({BaseNode? start}) : _start = start;

  /// The starting node of the flow.
  BaseNode? _start;

  /// Sets the starting [node] for the flow. This is the entry point for the
  /// execution of the flow.
  ///
  /// Returns the [node] that was set as the start node, allowing for chaining.
  BaseNode start(BaseNode node) {
    _start = node;
    return node;
  }

  /// Clones a node and its successors recursively.
  BaseNode? _cloneNode(
    BaseNode? originalNode,
    Map<BaseNode, BaseNode> clonedNodes, [
    Map<String, BaseNode>? namedNodes,
  ]) {
    if (originalNode == null) {
      return null;
    }
    if (clonedNodes.containsKey(originalNode)) {
      return clonedNodes[originalNode]!;
    }

    final clonedNode = originalNode.clone();
    clonedNodes[originalNode] = clonedNode;

    if (namedNodes != null && originalNode.name != null) {
      namedNodes[originalNode.name!] = clonedNode;
    }

    for (final entry in originalNode.successors.entries) {
      clonedNode.successors[entry.key] = _cloneNode(
        entry.value,
        clonedNodes,
        namedNodes,
      )!;
    }

    return clonedNode;
  }

  @override
  /// Executes the flow.
  ///
  /// This method clones the entire flow, including all nodes, to ensure that
  /// each execution is isolated. It then traverses the graph, executing each
  /// node in sequence.
  ///
  /// The [shared] map is passed to each node, allowing them to share data.
  ///
  /// Returns the result of the last executed node.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (_start == null) {
      throw StateError('The start node has not been set.');
    }

    final clonedNodes = <BaseNode, BaseNode>{};
    final namedNodes = <String, BaseNode>{};
    final clonedStart = _cloneNode(_start, clonedNodes, namedNodes);

    final nodeParams =
        shared['__node_params__'] as Map<String, Map<String, dynamic>>?;
    if (nodeParams != null) {
      for (final entry in nodeParams.entries) {
        final nodeName = entry.key;
        final params = entry.value;
        if (namedNodes.containsKey(nodeName)) {
          namedNodes[nodeName]!.params.addAll(params);
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

  /// Creates a deep copy of this [Flow].
  ///
  /// Subclasses can override this method to create a copy of the correct type,
  /// but they should call `super.clone()` to ensure the base properties are
  /// copied.
  T copy<T extends Flow>([T Function()? factory]) {
    final clonedFlow = ((factory != null ? factory() : Flow()) as T)
      ..name = name
      ..params = Map.from(params);

    if (_start != null) {
      final clonedNodes = <BaseNode, BaseNode>{};
      clonedFlow._start = _cloneNode(_start, clonedNodes);
    }

    return clonedFlow;
  }

  @override
  /// Creates a deep copy of this [Flow].
  Flow clone() {
    return copy();
  }
}
