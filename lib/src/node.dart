import 'dart:async';

import 'package:pocketflow/src/base_node.dart';

/// A class that represents a node in a PocketFlow workflow.
///
/// A `Node` is an extension of `BaseNode` that adds retry logic to the `exec`
/// method. This is useful for operations that might fail intermittently, such
/// as network requests.
class Node extends BaseNode {
  /// Creates a new `Node`.
  ///
  /// - [maxRetries]: The maximum number of times to retry the `exec` method.
  ///   Defaults to `1`.
  /// - [wait]: The duration to wait between retries. Defaults to
  ///   `Duration.zero`.
  Node({
    this.maxRetries = 1,
    this.wait = Duration.zero,
  });

  /// The maximum number of times to retry the `exec` method upon failure.
  final int maxRetries;

  /// The duration to wait between retries.
  final Duration wait;

  /// A fallback method that is called when the `exec` method fails after all
  /// retries have been exhausted.
  ///
  /// The default implementation re-throws the error. This method can be
  /// overridden to provide custom fallback logic, such as returning a
  /// default value or gracefully degrading functionality.
  Future<dynamic> execFallback(dynamic prepResult, Exception error) async {
    throw error;
  }

  @override
  /// Executes the node's lifecycle (`prep` -> `exec` -> `post`) with retry
  /// logic.
  ///
  /// If the `exec` method fails, it will be retried up to `maxRetries` times.
  /// A `wait` duration can be specified to delay between retries. If all
  /// retries fail, the `execFallback` method is called.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    final prepResult = await prep(shared);
    dynamic execResult;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        execResult = await exec(prepResult);
        break; // Success, exit loop
      } catch (e) {
        // If it's not an Exception, rethrow immediately. The retry logic is
        // only for recoverable Exceptions.
        if (e is! Exception) {
          rethrow;
        }

        // If it's the last attempt for a recoverable Exception, use fallback.
        if (attempt == maxRetries - 1) {
          execResult = await execFallback(prepResult, e);
          break; // Exit loop after fallback
        }

        if (wait > Duration.zero) {
          await Future<void>.delayed(wait);
        }
      }
    }

    return post(shared, prepResult, execResult);
  }
}
