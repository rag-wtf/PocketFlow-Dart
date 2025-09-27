import 'base_node.dart';

/// A node with retry logic and error handling capabilities.
///
/// Extends [BaseNode] to provide retry functionality with configurable
/// maximum retries and wait times between attempts.
abstract class Node<T> extends BaseNode<T> {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Wait time in milliseconds between retries
  final int waitMs;

  /// Current retry attempt (0-based)
  int _currentRetry = 0;

  /// Create a new Node with retry configuration
  ///
  /// [maxRetries] Maximum number of retry attempts (default: 1)
  /// [waitMs] Wait time in milliseconds between retries (default: 0)
  Node({this.maxRetries = 1, this.waitMs = 0});

  /// Get the current retry attempt number
  int get currentRetry => _currentRetry;

  /// Fallback execution when all retries are exhausted
  ///
  /// [prepRes] Result from preparation phase
  /// [exception] The exception that caused the failure
  /// Returns fallback result or rethrows the exception
  T? execFallback(dynamic prepRes, Exception exception) {
    throw exception;
  }

  /// Internal execution with retry logic
  @override
  T? internalExec(dynamic prepRes) {
    for (_currentRetry = 0; _currentRetry < maxRetries; _currentRetry++) {
      try {
        return exec(prepRes);
      } on Exception catch (e) {
        if (_currentRetry == maxRetries - 1) {
          return execFallback(prepRes, e);
        }
        if (waitMs > 0) {
          // In a real implementation, you might want to use async/await here
          // For now, we'll use a simple sleep simulation
          _sleep(waitMs);
        }
      }
    }
    return null; // This should never be reached
  }

  /// Simple sleep implementation (blocking)
  /// In a real async implementation, this would be replaced with await Future.delayed()
  void _sleep(int milliseconds) {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsedMilliseconds < milliseconds) {
      // Busy wait - not ideal but matches the Python implementation
    }
    stopwatch.stop();
  }
}
