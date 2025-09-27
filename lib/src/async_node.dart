import 'dart:async';
import 'node.dart';

/// An asynchronous node with retry logic and error handling capabilities.
///
/// Extends [Node] to provide async functionality using Dart's Future-based
/// async/await patterns.
abstract class AsyncNode<T> extends Node<T> {
  /// Create a new AsyncNode with retry configuration
  ///
  /// [maxRetries] Maximum number of retry attempts (default: 1)
  /// [waitMs] Wait time in milliseconds between retries (default: 0)
  AsyncNode({super.maxRetries = 1, super.waitMs = 0});

  /// Async preparation phase - override in subclasses
  ///
  /// [shared] Shared data context
  /// Returns Future with preparation result
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return prep(shared);
  }

  /// Async execution phase - override in subclasses
  ///
  /// [prepRes] Result from preparation phase
  /// Returns Future with execution result
  Future<T?> execAsync(dynamic prepRes);

  /// Async fallback execution when all retries are exhausted
  ///
  /// [prepRes] Result from preparation phase
  /// [exception] The exception that caused the failure
  /// Returns Future with fallback result or rethrows the exception
  Future<T?> execFallbackAsync(dynamic prepRes, Exception exception) async {
    throw exception;
  }

  /// Async post-processing phase - override in subclasses
  ///
  /// [shared] Shared data context
  /// [prepRes] Result from preparation phase
  /// [execRes] Result from execution phase
  /// Returns Future with post-processing result
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepRes,
    T? execRes,
  ) async {
    return post(shared, prepRes, execRes);
  }

  /// Internal async execution with retry logic
  Future<T?> internalExecAsync(dynamic prepRes) async {
    for (var currentRetry = 0; currentRetry < maxRetries; currentRetry++) {
      try {
        return await execAsync(prepRes);
      } on Exception catch (e) {
        if (currentRetry == maxRetries - 1) {
          return await execFallbackAsync(prepRes, e);
        }
        if (waitMs > 0) {
          await Future<void>.delayed(Duration(milliseconds: waitMs));
        }
      }
    }
    return null; // This should never be reached
  }

  /// Internal async run method that executes the full lifecycle
  Future<dynamic> internalRunAsync(Map<String, dynamic> shared) async {
    final prepRes = await prepAsync(shared);
    final execRes = await internalExecAsync(prepRes);
    return await postAsync(shared, prepRes, execRes);
  }

  /// Run this async node with the given shared context
  ///
  /// [shared] Shared data context
  /// Returns Future with the result of the post-processing phase
  Future<dynamic> runAsync(Map<String, dynamic> shared) async {
    if (successors.isNotEmpty) {
      print('Warning: Node won\'t run successors. Use AsyncFlow.');
    }
    return await internalRunAsync(shared);
  }

  /// Override the synchronous run method to throw an error
  @override
  dynamic run(Map<String, dynamic> shared) {
    throw UnsupportedError('Use runAsync() for AsyncNode');
  }

  /// Override the synchronous exec method - not used in async nodes
  @override
  T? exec(dynamic prepRes) {
    throw UnsupportedError('Use execAsync() for AsyncNode');
  }
}
