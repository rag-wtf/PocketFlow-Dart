import 'package:pocketflow/src/node.dart';

/// A function type for an asynchronous execution block.
typedef AsyncExecFunction = Future<dynamic> Function(dynamic prepResult);

/// A class for defining nodes with true async lifecycle methods.
///
/// `AsyncNode` extends [Node] and provides async versions of the lifecycle
/// methods that can be overridden by subclasses. This matches Python's
/// AsyncNode design where async methods are the primary interface.
///
/// Unlike the base Node class, AsyncNode provides separate async lifecycle
/// methods that should be overridden instead of the base sync methods.
class AsyncNode extends Node {
  /// Creates a new `AsyncNode`.
  ///
  /// - [maxRetries]: The maximum number of times to retry the
  ///   `execAsync` method.
  /// - [wait]: The duration to wait between retries.
  AsyncNode({
    super.maxRetries = 1,
    super.wait = Duration.zero,
  });

  /// Async pre-processing logic before `execAsync`.
  ///
  /// This method is called before the `execAsync` method. It can be used to
  /// prepare data for the `execAsync` method. The [shared] map contains data
  /// that is shared across all nodes in the workflow.
  ///
  /// Returns a value that will be passed to the `execAsync` method.
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    // Default implementation does nothing.
  }

  /// The main async execution logic for the node.
  ///
  /// This method is called after the `prepAsync` method. It should contain the
  /// main async logic for the node. The [prepResult] is the value returned by
  /// the `prepAsync` method.
  ///
  /// Returns a value that will be passed to the `postAsync` method.
  Future<dynamic> execAsync(dynamic prepResult) async {
    // Default implementation does nothing.
  }

  /// Async fallback method for when execAsync fails after all retries.
  ///
  /// The [prepResult] is the result from the `prepAsync` method, and the
  /// [error] is the exception that was caught during the last attempt of the
  /// `execAsync` method.
  ///
  /// The default implementation re-throws the error.
  Future<dynamic> execFallbackAsync(dynamic prepResult, Exception error) async {
    throw error;
  }

  /// Async post-processing logic after `execAsync`.
  ///
  /// This method is called after the `execAsync` method. It can be used to
  /// process the result of the `execAsync` method and update the [shared] map.
  /// The [prepResult] is the value returned by the `prepAsync` method, and the
  /// [execResult] is the value returned by the `execAsync` method.
  ///
  /// Returns a value that will be returned by the `runAsync` method.
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Default implementation returns the execution result.
    return execResult;
  }

  /// Internal async execution with retry logic.
  ///
  /// This method implements the retry logic for async operations.
  Future<dynamic> _execAsync(dynamic prepResult) async {
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await execAsync(prepResult);
      } catch (e) {
        // If it's not an Exception, rethrow immediately.
        if (e is! Exception) {
          rethrow;
        }

        // If it's the last attempt, use fallback.
        if (attempt == maxRetries - 1) {
          return execFallbackAsync(prepResult, e);
        }

        if (wait > Duration.zero) {
          await Future<void>.delayed(wait);
        }
      }
    }
  }

  /// Internal async lifecycle execution.
  ///
  /// This method orchestrates the async lifecycle:
  /// prepAsync -> execAsync -> postAsync.
  Future<dynamic> _runAsync(Map<String, dynamic> shared) async {
    final prepResult = await prepAsync(shared);
    final execResult = await _execAsync(prepResult);
    return postAsync(shared, prepResult, execResult);
  }

  /// Async version of run that uses the async lifecycle methods.
  ///
  /// This method should be used for AsyncNode instead of the base run method.
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    if (successors.isNotEmpty) {
      log(
        'Warning: Calling runAsync() on a node with successors has no effect '
        'on flow execution. To execute the entire flow, call run() on the '
        'AsyncFlow instance instead.',
      );
    }
    return _runAsync(shared);
  }

  @override
  /// Sync run method delegates to runAsync for compatibility.
  ///
  /// While AsyncNode should preferably use runAsync(), this provides
  /// compatibility with existing Flow implementations.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    return runAsync(shared);
  }

  @override
  /// Creates a copy of this [AsyncNode].
  AsyncNode clone() {
    return AsyncNode(
        maxRetries: maxRetries,
        wait: wait,
      )
      ..name = name
      ..params = Map.from(params);
  }
}

/// A convenience class that wraps a function as an AsyncNode.
///
/// This provides the function-based pattern for simple cases while keeping
/// the inheritance model as the primary AsyncNode interface.
class SimpleAsyncNode extends AsyncNode {
  /// Creates a new `SimpleAsyncNode`.
  ///
  /// - [execFunction]: The asynchronous function to be executed by this node.
  SimpleAsyncNode(AsyncExecFunction execFunction)
    : _execFunction = execFunction;

  /// The asynchronous function to be executed by this node.
  final AsyncExecFunction _execFunction;

  @override
  /// Prepares the data for the `execAsync` method.
  ///
  /// This implementation returns the [shared] map to maintain compatibility
  /// with the original function-based AsyncNode behavior.
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return shared;
  }

  @override
  /// Executes the asynchronous function.
  ///
  /// This method calls the [_execFunction] that was passed to the constructor.
  Future<dynamic> execAsync(dynamic prepResult) {
    return _execFunction(prepResult);
  }

  @override
  /// Creates a copy of this [SimpleAsyncNode].
  SimpleAsyncNode clone() {
    return SimpleAsyncNode(_execFunction)
      ..name = name
      ..params = Map.from(params);
  }
}
