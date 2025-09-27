import 'base_node.dart';

/// A flow orchestrates the execution of multiple nodes in sequence.
///
/// Manages the workflow by executing nodes and following their successor
/// relationships based on the actions returned by each node.
class Flow<T> extends BaseNode<T> {
  /// The starting node of the flow
  BaseNode<dynamic>? _startNode;

  /// Create a new Flow
  ///
  /// [startNode] Optional starting node for the flow
  Flow([BaseNode<dynamic>? startNode]) : _startNode = startNode;

  /// Get the current start node
  BaseNode<dynamic>? get startNode => _startNode;

  /// Set the starting node for this flow
  ///
  /// [startNode] The node to start the flow with
  /// Returns the start node for chaining
  BaseNode<U> start<U>(BaseNode<U> startNode) {
    _startNode = startNode;
    return startNode;
  }

  /// Get the next node based on current node and action
  ///
  /// [currentNode] The current node in execution
  /// [action] The action returned by the current node
  /// Returns the next node to execute, or null if no successor found
  BaseNode<dynamic>? getNextNode(
    BaseNode<dynamic> currentNode,
    dynamic action,
  ) {
    final actionStr = action?.toString() ?? 'default';
    final nextNode = currentNode.successors[actionStr];

    if (nextNode == null && currentNode.successors.isNotEmpty) {
      final availableActions = currentNode.successors.keys.toList();
      print(
        'Warning: Flow ends: \'$actionStr\' not found in $availableActions',
      );
    }

    return nextNode;
  }

  /// Create a deep copy of a node to avoid state conflicts during execution
  BaseNode<dynamic> _copyNode(BaseNode<dynamic> node) {
    // In a real implementation, this would create a proper deep copy
    // For now, we'll return the same node but reset its parameters
    // This is a simplified approach - in production you'd want proper cloning
    return node;
  }

  /// Internal orchestration method that executes the flow
  ///
  /// [shared] Shared data context
  /// [params] Optional parameters to merge with node parameters
  /// Returns the last action from the final node
  dynamic internalOrchestrate(
    Map<String, dynamic> shared, [
    Map<String, dynamic>? params,
  ]) {
    if (_startNode == null) {
      throw StateError('Flow has no start node');
    }

    BaseNode<dynamic>? currentNode = _copyNode(_startNode!);
    final mergedParams = <String, dynamic>{
      ...this.params,
      if (params != null) ...params,
    };

    dynamic lastAction;

    while (currentNode != null) {
      currentNode.setParams(mergedParams);
      lastAction = currentNode.internalRun(shared);
      final nextNode = getNextNode(currentNode, lastAction);
      currentNode = nextNode != null ? _copyNode(nextNode) : null;
    }

    return lastAction;
  }

  /// Internal run method for the flow
  @override
  dynamic internalRun(Map<String, dynamic> shared) {
    final prepRes = prep(shared);
    final orchestrationResult = internalOrchestrate(shared);
    return post(shared, prepRes, orchestrationResult);
  }

  /// Execute method for Flow (not typically overridden)
  @override
  T? exec(dynamic prepRes) {
    // Flow doesn't have a traditional exec method
    // The orchestration happens in internalRun
    return null;
  }

  /// Post-processing for Flow
  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, dynamic execRes) {
    return execRes;
  }
}
