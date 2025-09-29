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

  /// Gets the next node based on the current node and action.
  ///
  /// This method implements the original Dart Flow transition logic
  /// while supporting Python's action-based pattern.
  ///
  /// Logic:
  /// 1. If action is a String and there's a successor for it, use that
  /// 2. Otherwise, fall back to 'default' successor
  /// 3. If no successor found, return null (flow ends)
  BaseNode? getNextNode(BaseNode curr, dynamic action) {
    BaseNode? next;

    // First try exact string match (original Dart logic)
    if (action is String && curr.successors.containsKey(action)) {
      next = curr.successors[action];
    }
    // Fall back to 'default' (original Dart logic)
    else if (curr.successors.containsKey('default')) {
      next = curr.successors['default'];
    }
    // No successor found - flow ends
    else {
      next = null;
    }

    // Log warning if flow ends unexpectedly (Python pattern)
    if (next == null && curr.successors.isNotEmpty) {
      curr.log(
        "Warning: Flow ends: '$action' not found in "
        '${curr.successors.keys.toList()}',
      );
    }

    return next;
  }

  /// Core orchestration method that executes the flow graph.
  ///
  /// This method implements Python's _orch pattern:
  /// 1. Clone the start node
  /// 2. Set parameters (merged with flow params)
  /// 3. Execute nodes in sequence based on action-based transitions
  /// 4. Return the last action/result
  ///
  /// Matches Python's implementation:
  /// ```python
  /// def _orch(self,shared,params=None):
  ///     curr,p,last_action =copy.copy(self.start_node),
  ///                         (params or {**self.params}),None
  ///     while curr:
  ///         curr.set_params(p); last_action=curr._run(shared)
  ///         curr=copy.copy(self.get_next_node(curr,last_action))
  ///     return last_action
  /// ```
  Future<dynamic> orch(
    Map<String, dynamic> shared, [
    Map<String, dynamic>? params,
  ]) async {
    if (_start == null) {
      throw StateError('The start node has not been set.');
    }

    final clonedNodes = <BaseNode, BaseNode>{};
    final namedNodes = <String, BaseNode>{};
    var curr = _cloneNode(_start, clonedNodes, namedNodes);

    // Merge flow params with provided params (provided params take precedence)
    final p = params ?? <String, dynamic>{...this.params};

    // Handle node-specific parameters
    final nodeParams =
        shared['__node_params__'] as Map<String, Map<String, dynamic>>?;
    if (nodeParams != null) {
      for (final entry in nodeParams.entries) {
        final nodeName = entry.key;
        final nodeSpecificParams = entry.value;
        if (namedNodes.containsKey(nodeName)) {
          namedNodes[nodeName]!.params.addAll(nodeSpecificParams);
        }
      }
    }

    dynamic lastAction;

    while (curr != null) {
      // Set parameters on current node
      curr.params.addAll(p);

      // Execute current node
      lastAction = await curr.run(shared);

      // Get next node based on action
      curr = getNextNode(curr, lastAction);
      if (curr != null) {
        curr = _cloneNode(curr, clonedNodes, namedNodes);
      }
    }

    return lastAction;
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
  /// The main execution logic for the flow.
  ///
  /// This method implements Python's Flow pattern where exec calls _orch.
  /// It orchestrates the execution of the flow graph using the orch method.
  ///
  /// Matches Python's pattern:
  /// ```python
  /// def _run(self,shared):
  ///     p=self.prep(shared); o=self._orch(shared)
  ///     return self.post(shared,p,o)
  /// ```
  Future<dynamic> exec(dynamic prepResult) async {
    return orch(shared);
  }

  /// Shared storage reference for use in exec method.
  /// This is set by the run method before calling exec.
  late Map<String, dynamic> shared;

  @override
  /// Executes the flow following the Node lifecycle pattern.
  ///
  /// This method follows Python's Flow pattern:
  /// 1. Calls prep(shared) to prepare
  /// 2. Calls exec(prepResult) which calls orch(shared)
  /// 3. Calls post(shared, prepResult, execResult)
  ///
  /// This aligns with Python's _run method in Flow.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    // Store shared for use in exec method
    this.shared = shared;

    // Follow the Node lifecycle: prep -> exec -> post
    final prepResult = await prep(shared);
    final execResult = await exec(prepResult);
    return post(shared, prepResult, execResult);
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
