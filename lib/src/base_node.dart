import 'dart:async';

/// A helper class to represent a pending conditional transition.
class ConditionalTransition {
  /// Creates a new conditional transition.
  ConditionalTransition(this.from, this.action);

  /// The source node of the transition.
  final BaseNode from;

  /// The action that triggers the transition.
  final String action;

  /// Chains the transition to the [to] node.
  BaseNode operator >>(BaseNode to) {
    return from.next(to, action: action);
  }
}

/// An abstract class representing a node in a workflow.
abstract class BaseNode {
  /// The unique name of the node.
  String? name;

  /// The parameters for the node.
  Map<String, dynamic> params = {};

  /// The successor nodes.
  final Map<String, BaseNode> successors = {};

  /// Defines the next node in the sequence.
  BaseNode next(BaseNode node, {String action = 'default'}) {
    if (successors.containsKey(action)) {
      print(
        'Warning: Overwriting existing successor for action "$action" on node '
        '"${name ?? runtimeType}".',
      );
    }
    successors[action] = node;
    return node;
  }

  /// Chains the current node to the [other] node.
  ///
  /// This is a shorthand for `next(other)`.
  BaseNode operator >>(BaseNode other) {
    return next(other);
  }

  /// Creates a conditional transition with the given [action].
  ///
  /// This is used with the `>>` operator to chain nodes conditionally.
  ConditionalTransition operator -(String action) {
    return ConditionalTransition(this, action);
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
    // Default implementation returns the execution result.
    return execResult;
  }

  /// Executes the node's lifecycle (`prep` -> `exec` -> `post`).
  Future<dynamic> run(Map<String, dynamic> shared) async {
    if (successors.isNotEmpty) {
      print(
        'Warning: Calling run() on a node with successors has no effect on '
        'flow execution. To execute the entire flow, call run() on the Flow '
        'instance instead.',
      );
    }
    final prepResult = await prep(shared);
    final execResult = await exec(prepResult);
    return post(shared, prepResult, execResult);
  }

  /// Creates a copy of the node.
  ///
  /// Subclasses should implement this method to support cloning of nodes.
  BaseNode clone();
}
