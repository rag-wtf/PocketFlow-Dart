import 'dart:async';

/// An abstract class representing a node in a workflow.
abstract class BaseNode {
  /// The parameters for the node.
  Map<String, dynamic> params = {};

  /// The successor nodes.
  final Map<String, BaseNode> successors = {};

  /// Defines the next node in the sequence.
  BaseNode next(BaseNode node, {String action = 'default'}) {
    successors[action] = node;
    return node;
  }

  /// Pre-processing logic before `exec`.
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    // Default implementation does nothing.
  }

  /// The main execution logic for the node.
  Future<dynamic> exec(dynamic prepResult) async {
    // Default implementation does nothing.
  }

  /// Post-processing logic after `exec`.
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Default implementation does nothing.
  }

  /// Executes the node's lifecycle (`prep` -> `exec` -> `post`).
  Future<dynamic> run(Map<String, dynamic> shared) async {
    final prepResult = await prep(shared);
    final execResult = await exec(prepResult);
    return post(shared, prepResult, execResult);
  }

  /// Creates a copy of the node.
  ///
  /// Subclasses should implement this method to support cloning of nodes.
  BaseNode clone();
}