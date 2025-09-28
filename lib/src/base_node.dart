import 'dart:async';

/// A helper class to represent a pending conditional transition.
///
/// This class is used to chain nodes conditionally using the `-` and `>>`
/// operators. For example:
///
/// ```dart
/// nodeA - 'success' >> nodeB;
/// nodeA - 'failure' >> nodeC;
/// ```
class ConditionalTransition {
  /// Creates a new conditional transition.
  ConditionalTransition(this.from, this.action);

  /// The source node of the transition.
  final BaseNode from;

  /// The action that triggers the transition.
  final String action;

  /// Chains the transition to the [to] node.
  ///
  /// This is equivalent to `from.next(to, action: action)`.
  BaseNode operator >>(BaseNode to) {
    return from.next(to, action: action);
  }
}

/// An abstract class representing a node in a workflow.
///
/// A node is a single step in a workflow. It can be connected to other nodes
/// to form a directed acyclic graph (DAG). Each node has a `prep` method for
/// pre-processing, an `exec` method for the main execution logic, and a `post`
/// method for post-processing.
abstract class BaseNode {
  /// The unique name of the node.
  ///
  /// This is used to identify the node in the workflow. If not provided, the
  /// runtime type of the node is used.
  String? name;

  /// The parameters for the node.
  ///
  /// These parameters can be used to configure the node's behavior. They are
  /// accessible within the `prep`, `exec`, and `post` methods.
  Map<String, dynamic> params = {};

  /// The successor nodes.
  ///
  /// This is a map of action names to successor nodes. When a node finishes
  /// execution, it can return an action name to determine which node to
  /// execute next.
  final Map<String, BaseNode> successors = {};

  /// Defines the next node in the sequence.
  ///
  /// This method is used to connect nodes in a workflow. The [action] parameter
  /// can be used to create conditional transitions.
  ///
  /// Returns the [node] for chaining.
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
  ///
  /// ```dart
  /// nodeA - 'success' >> nodeB;
  /// ```
  ConditionalTransition operator -(String action) {
    return ConditionalTransition(this, action);
  }

  /// Pre-processing logic before `exec`.
  ///
  /// This method is called before the `exec` method. It can be used to prepare
  /// data for the `exec` method. The [shared] map contains data that is
  /// shared across all nodes in the workflow.
  ///
  /// Returns a value that will be passed to the `exec` method.
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    // Default implementation does nothing.
  }

  /// The main execution logic for the node.
  ///
  /// This method is called after the `prep` method. It should contain the main
  /// logic for the node. The [prepResult] is the value returned by the `prep`
  /// method.
  ///
  /// Returns a value that will be passed to the `post` method.
  Future<dynamic> exec(dynamic prepResult) async {
    // Default implementation does nothing.
  }

  /// Post-processing logic after `exec`.
  ///
  /// This method is called after the `exec` method. It can be used to process
  /// the result of the `exec` method and update the [shared] map. The
  /// [prepResult] is the value returned by the `prep` method, and the
  /// [execResult] is the value returned by the `exec` method.
  ///
  /// Returns a value that will be returned by the `run` method.
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Default implementation returns the execution result.
    return execResult;
  }

  /// Executes the node's lifecycle (`prep` -> `exec` -> `post`).
  ///
  /// This method is called by the workflow to execute the node. It orchestrates
  /// the call to `prep`, `exec`, and `post` methods. It should not be called
  /// directly unless for testing purposes.
  ///
  /// The [shared] map contains data that is shared across all nodes in the
  /// workflow.
  ///
  /// Returns the result of the `post` method.
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
