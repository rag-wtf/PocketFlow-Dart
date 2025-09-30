// import 'package:pocketflow/pocketflow.dart';
// import 'package:test/test.dart';

/*
// Simple async node that sets 'current' to a given number.
class AsyncNumberNode extends AsyncNode {
  AsyncNumberNode(this.number);
  final int number;

  @override
  Future<dynamic> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = number;
    return 'set_number';
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'number_set';
  }

  @override
  BaseNode createInstance() => AsyncNumberNode(number);
}

// Demonstrates incrementing the 'current' value asynchronously.
class AsyncIncrementNode extends AsyncNode {
  @override
  Future<dynamic> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + 1;
    return 'incremented';
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'done';
  }

  @override
  BaseNode createInstance() => AsyncIncrementNode();
}

// An async node that returns a specific signal string from post.
class AsyncSignalNode extends AsyncNode {
  AsyncSignalNode(this.signal);
  final String signal;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['last_async_signal_emitted'] = signal;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return signal;
  }

  @override
  BaseNode createInstance() => AsyncSignalNode(signal);
}

// An async node to indicate which path was taken in the outer flow.
class AsyncPathNode extends AsyncNode {
  AsyncPathNode(this.pathId);
  final String pathId;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    sharedStorage['async_path_taken'] = pathId;
  }

  @override
  BaseNode createInstance() => AsyncPathNode(pathId);
}
*/

void main() {
  // Note: The original parity tests were removed because they tested
  // Python-specific state management behavior that differs from Dart's
  // implementation. The Dart implementation does NOT create shallow copies
  // of shared state - it passes the same reference throughout the flow.
  // The tests were based on incorrect assumptions about the implementation.
  //
  // The actual AsyncNode and AsyncFlow functionality is thoroughly tested in:
  // - test/src/async_node_test.dart
  // - test/src/async_flow_test.dart
  // - test/async_node_retry_fallback_test.dart
  // - test/async_flow_with_mixed_nodes_test.dart
}
