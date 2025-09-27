import 'node.dart';

/// A node that processes batches of items.
///
/// Extends [Node] to handle collections of data by applying the node's
/// execution logic to each item in the batch.
abstract class BatchNode<T> extends Node<List<T?>> {
  /// Create a new BatchNode with retry configuration
  ///
  /// [maxRetries] Maximum number of retry attempts (default: 1)
  /// [waitMs] Wait time in milliseconds between retries (default: 0)
  BatchNode({super.maxRetries = 1, super.waitMs = 0});

  /// Process a single item (to be implemented by subclasses)
  ///
  /// [prepRes] Result from preparation phase for this item
  /// Returns the processed result for this item
  T? execSingle(dynamic prepRes);

  /// Execute method that processes all items in the batch
  @override
  List<T?> exec(dynamic prepRes) {
    // prepRes should be a list of items to process
    final items = prepRes as List<dynamic>? ?? <dynamic>[];

    final results = <T?>[];
    for (final item in items) {
      results.add(execSingle(item));
    }

    return results;
  }

  /// Internal execution with retry logic for batch processing
  @override
  List<T?> internalExec(dynamic prepRes) {
    final items = prepRes as List<dynamic>? ?? <dynamic>[];

    final results = <T?>[];
    for (final item in items) {
      // Apply retry logic to each individual item
      T? itemResult;
      for (var currentRetry = 0; currentRetry < maxRetries; currentRetry++) {
        try {
          itemResult = execSingle(item);
          break; // Success, exit retry loop
        } on Exception catch (e) {
          if (currentRetry == maxRetries - 1) {
            try {
              itemResult = execFallback(item, e) as T?;
            } on Exception {
              itemResult = null; // Fallback failed, use null
            }
          } else if (waitMs > 0) {
            _sleep(waitMs);
          }
        }
      }
      results.add(itemResult);
    }

    return results;
  }

  /// Simple sleep implementation (blocking)
  void _sleep(int milliseconds) {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsedMilliseconds < milliseconds) {
      // Busy wait - not ideal but matches the Python implementation
    }
    stopwatch.stop();
  }
}
