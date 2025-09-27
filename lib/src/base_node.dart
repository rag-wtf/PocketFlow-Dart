/// Base class for all nodes in the PocketFlow framework.
///
/// Provides core functionality for node execution lifecycle, parameter management,
/// and successor node chaining.
abstract class BaseNode<T> {
  /// Parameters for this node
  Map<String, dynamic> _params = <String, dynamic>{};

  /// Map of action names to successor nodes
  final Map<String, BaseNode<dynamic>> _successors =
      <String, BaseNode<dynamic>>{};

  /// Get the current parameters
  Map<String, dynamic> get params => Map<String, dynamic>.from(_params);

  /// Get the current successors
  Map<String, BaseNode<dynamic>> get successors =>
      Map<String, BaseNode<dynamic>>.from(_successors);

  /// Set parameters for this node
  void setParams(Map<String, dynamic> params) {
    _params = Map<String, dynamic>.from(params);
  }

  /// Add a successor node for the given action
  ///
  /// [node] The successor node to add
  /// [action] The action name (defaults to "default")
  /// Returns the added node for chaining
  BaseNode<U> next<U>(BaseNode<U> node, [String action = 'default']) {
    if (_successors.containsKey(action)) {
      // In Dart, we'll use print instead of warnings.warn
      print('Warning: Overwriting successor for action \'$action\'');
    }
    _successors[action] = node;
    return node;
  }

  /// Preparation phase - override in subclasses
  ///
  /// [shared] Shared data context
  /// Returns preparation result
  dynamic prep(Map<String, dynamic> shared) {
    return null;
  }

  /// Execution phase - override in subclasses
  ///
  /// [prepRes] Result from preparation phase
  /// Returns execution result
  T? exec(dynamic prepRes);

  /// Post-processing phase - override in subclasses
  ///
  /// [shared] Shared data context
  /// [prepRes] Result from preparation phase
  /// [execRes] Result from execution phase
  /// Returns post-processing result (typically an action string)
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, T? execRes) {
    return null;
  }

  /// Internal execution wrapper - can be overridden for custom behavior
  T? internalExec(dynamic prepRes) {
    return exec(prepRes);
  }

  /// Internal run method that executes the full lifecycle
  dynamic internalRun(Map<String, dynamic> shared) {
    final prepRes = prep(shared);
    final execRes = internalExec(prepRes);
    return post(shared, prepRes, execRes);
  }

  /// Run this node with the given shared context
  ///
  /// [shared] Shared data context
  /// Returns the result of the post-processing phase
  dynamic run(Map<String, dynamic> shared) {
    if (_successors.isNotEmpty) {
      print('Warning: Node won\'t run successors. Use Flow.');
    }
    return internalRun(shared);
  }

  /// Operator overload for chaining nodes with >>
  ///
  /// Example: nodeA >> nodeB
  BaseNode<dynamic> operator >>(BaseNode<dynamic> other) {
    return next(other);
  }

  /// Operator overload for conditional transitions with -
  ///
  /// Example: nodeA - 'success' >> nodeB
  _ConditionalTransition operator -(String action) {
    return _ConditionalTransition(this, action);
  }
}

/// Helper class for conditional transitions
class _ConditionalTransition {
  final BaseNode<dynamic> _sourceNode;
  final String _action;

  _ConditionalTransition(this._sourceNode, this._action);

  /// Complete the conditional transition
  BaseNode<dynamic> operator >>(BaseNode<dynamic> targetNode) {
    return _sourceNode.next(targetNode, _action);
  }
}
