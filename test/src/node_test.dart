import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Test implementation of Node
class TestNode extends Node<String> {
  String? _execResult;
  bool _shouldThrow;
  int _throwOnAttempt;

  TestNode({
    String? execResult,
    bool shouldThrow = false,
    int throwOnAttempt = 0,
    super.maxRetries = 1,
    super.waitMs = 0,
  }) : _execResult = execResult,
       _shouldThrow = shouldThrow,
       _throwOnAttempt = throwOnAttempt;

  @override
  String? exec(dynamic prepRes) {
    if (_shouldThrow &&
        (_throwOnAttempt == 0 || currentRetry == _throwOnAttempt - 1)) {
      throw Exception('Test exception');
    }
    return _execResult;
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    return execRes; // Return the exec result instead of null
  }
}

// Test node with custom fallback
class TestNodeWithFallback extends TestNode {
  final String _fallbackResult;

  TestNodeWithFallback(
    this._fallbackResult, {
    super.shouldThrow = true,
    super.maxRetries = 2,
  });

  @override
  String? execFallback(dynamic prepRes, Exception exception) {
    return _fallbackResult;
  }
}

void main() {
  group('Node', () {
    late TestNode node;
    late Map<String, dynamic> shared;

    setUp(() {
      node = TestNode(execResult: 'test_result');
      shared = <String, dynamic>{'key': 'value'};
    });

    test('can be instantiated with default values', () {
      expect(node, isNotNull);
      expect(node.maxRetries, equals(1));
      expect(node.waitMs, equals(0));
      expect(node.currentRetry, equals(0));
    });

    test('can be instantiated with custom values', () {
      final customNode = TestNode(maxRetries: 3, waitMs: 100);
      expect(customNode.maxRetries, equals(3));
      expect(customNode.waitMs, equals(100));
    });

    test('successful execution on first attempt', () {
      final result = node.internalExec('prep_result');
      expect(result, equals('test_result'));
      expect(node.currentRetry, equals(0));
    });

    test('execFallback rethrows exception by default', () {
      final throwingNode = TestNode(shouldThrow: true);
      expect(() => throwingNode.internalExec('prep_result'), throwsException);
    });

    test('retry logic with eventual success', () {
      // Node that throws on first attempt but succeeds on second
      final retryNode = TestNode(
        execResult: 'success_after_retry',
        shouldThrow: true,
        throwOnAttempt: 1, // Throw only on first attempt (0-based)
        maxRetries: 2,
      );

      final result = retryNode.internalExec('prep_result');
      expect(result, equals('success_after_retry'));
      expect(retryNode.currentRetry, equals(1)); // Should have retried once
    });

    test('retry exhaustion calls execFallback', () {
      final fallbackNode = TestNodeWithFallback(
        'fallback_result',
        maxRetries: 2,
      );

      final result = fallbackNode.internalExec('prep_result');
      expect(result, equals('fallback_result'));
      expect(fallbackNode.currentRetry, equals(1)); // Last retry attempt
    });

    test('wait between retries', () {
      final waitNode = TestNode(
        shouldThrow: true,
        maxRetries: 2,
        waitMs: 10, // Small wait for testing
      );

      final stopwatch = Stopwatch()..start();
      expect(() => waitNode.internalExec('prep_result'), throwsException);
      stopwatch.stop();

      // Should have waited at least once (between first and second attempt)
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
    });

    test('no wait on last retry attempt', () {
      final waitNode = TestNode(
        shouldThrow: true,
        maxRetries: 1, // Only one attempt, so no wait
        waitMs: 100,
      );

      final stopwatch = Stopwatch()..start();
      expect(() => waitNode.internalExec('prep_result'), throwsException);
      stopwatch.stop();

      // Should not have waited since there's only one attempt
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('currentRetry is updated during execution', () {
      var capturedRetries = <int>[];

      final trackingNode = TestNode(maxRetries: 3);
      // Override exec to capture retry counts
      trackingNode._execResult = null;

      // Create a custom node that tracks retries
      final customNode = _TrackingNode(capturedRetries, maxRetries: 3);

      expect(() => customNode.internalExec('prep_result'), throwsException);
      expect(
        capturedRetries,
        equals([0, 1, 2]),
      ); // Should track all retry attempts
    });

    test('successful execution resets retry counter for next call', () {
      final result1 = node.internalExec('prep_result');
      expect(result1, equals('test_result'));
      expect(node.currentRetry, equals(0));

      final result2 = node.internalExec('prep_result');
      expect(result2, equals('test_result'));
      expect(node.currentRetry, equals(0));
    });

    test('inherits BaseNode functionality', () {
      final successor = TestNode();
      node >> successor;

      expect(node.successors['default'], same(successor));

      final result = node.run(shared);
      expect(result, equals('test_result'));
    });
  });
}

// Helper class to track retry attempts
class _TrackingNode extends Node<String> {
  final List<int> _capturedRetries;

  _TrackingNode(this._capturedRetries, {super.maxRetries = 1});

  @override
  String? exec(dynamic prepRes) {
    _capturedRetries.add(currentRetry);
    throw Exception('Always throw for testing');
  }
}
