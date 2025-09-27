import 'dart:async';
import 'base_node.dart';
import 'flow.dart';
import 'async_node.dart';

/// An asynchronous flow that orchestrates async node execution.
///
/// Extends [Flow] to provide async functionality for orchestrating
/// both synchronous and asynchronous nodes.
class AsyncFlow<T> extends Flow<T> {
  /// Create a new AsyncFlow
  ///
  /// [startNode] Optional starting node for the flow
  AsyncFlow([super.startNode]);

  /// Create a copy of a node to avoid state conflicts during execution
  BaseNode<dynamic> _copyNode(BaseNode<dynamic> node) {
    // In a real implementation, this would create a proper deep copy
    // For now, we'll return the same node but reset its parameters
    // This is a simplified approach - in production you'd want proper cloning
    return node;
  }

  /// Internal async orchestration method that executes the flow
  ///
  /// [shared] Shared data context
  /// [params] Optional parameters to merge with node parameters
  /// Returns Future with the last action from the final node
  Future<dynamic> internalOrchestrateAsync(
    Map<String, dynamic> shared, [
    Map<String, dynamic>? params,
  ]) async {
    if (startNode == null) {
      throw StateError('Flow has no start node');
    }

    BaseNode<dynamic>? currentNode = _copyNode(startNode!);
    final mergedParams = <String, dynamic>{
      ...this.params,
      if (params != null) ...params,
    };

    dynamic lastAction;

    while (currentNode != null) {
      currentNode.setParams(mergedParams);

      // Check if the current node is async and handle accordingly
      if (currentNode is AsyncNode) {
        lastAction = await currentNode.internalRunAsync(shared);
      } else {
        lastAction = currentNode.internalRun(shared);
      }

      final nextNode = getNextNode(currentNode, lastAction);
      currentNode = nextNode != null ? _copyNode(nextNode) : null;
    }

    return lastAction;
  }

  /// Internal async run method for the flow
  Future<dynamic> internalRunAsync(Map<String, dynamic> shared) async {
    final prepRes = await prepAsync(shared);
    final orchestrationResult = await internalOrchestrateAsync(shared);
    return await postAsync(shared, prepRes, orchestrationResult);
  }

  /// Async preparation phase
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return prep(shared);
  }

  /// Async post-processing phase
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepRes,
    dynamic execRes,
  ) async {
    return post(shared, prepRes, execRes);
  }

  /// Run this async flow with the given shared context
  ///
  /// [shared] Shared data context
  /// Returns Future with the result of the post-processing phase
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    if (successors.isNotEmpty) {
      print('Warning: Flow won\'t run successors. Use nested flows.');
    }
    return await internalRunAsync(shared);
  }

  /// Override the synchronous run method to throw an error
  @override
  dynamic run(Map<String, dynamic> shared) {
    throw UnsupportedError('Use runAsync() for AsyncFlow');
  }
}
