import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// --- Node Definitions from test_flow_basic.py ---

class NumberNode extends Node {
  NumberNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = number;
  }
}

class AddNode extends Node {
  AddNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }
}

class MultiplyNode extends Node {
  MultiplyNode(this.number);
  final int number;

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
  }
}

// A test node that can be configured to fail.
class FallibleNode extends Node {

  FallibleNode({
    this.failCount = 0,
    this.successValue = 'success',
    this.fallbackValue = 'fallback',
    this.useCustomFallback = false,
    this.rethrowNonException = false,
    super.maxRetries,
    super.wait,
  });
  int attempts = 0;
  final int failCount;
  final dynamic successValue;
  final dynamic fallbackValue;
  final bool useCustomFallback;
  final bool rethrowNonException;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    attempts++;
    if (attempts <= failCount) {
      if (rethrowNonException) {
        throw 'a non-exception error';
      }
      throw Exception('Failed on attempt $attempts');
    }
    return successValue;
  }

  @override
  Future<dynamic> execFallback(dynamic prepResult, Exception error) async {
    if (useCustomFallback) {
      return fallbackValue;
    }
    return super.execFallback(prepResult, error);
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Return the execResult so it can be asserted in tests.
    return execResult;
  }
}

void main() {
  group('Node', () {
    test('NumberNode sets the initial value correctly', () async {
      final node = NumberNode(42);
      final storage = <String, dynamic>{};
      await node.run(storage);
      expect(storage['current'], 42);
    });

    test('AddNode adds to the value correctly', () async {
      final node = AddNode(10);
      final storage = <String, dynamic>{'current': 5};
      await node.run(storage);
      expect(storage['current'], 15);
    });

    test('MultiplyNode multiplies the value correctly', () async {
      final node = MultiplyNode(3);
      final storage = <String, dynamic>{'current': 5};
      await node.run(storage);
      expect(storage['current'], 15);
    });
  });

  group('Node retry and fallback', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('should succeed on the first attempt if failCount is 0', () async {
      final node = FallibleNode(maxRetries: 3);
      final result = await node.run(sharedStorage);
      expect(result, 'success');
      expect(node.attempts, 1);
    });

    test('should succeed on retry if failCount is within maxRetries', () async {
      final node = FallibleNode(failCount: 2, maxRetries: 3);
      final result = await node.run(sharedStorage);
      expect(result, 'success');
      expect(node.attempts, 3);
    });

    test(
      'should rethrow the exception if retries are exhausted with default fallback',
      () async {
        final node = FallibleNode(failCount: 3, maxRetries: 2);
        await expectLater(
          () => node.run(sharedStorage),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('should call custom fallback when retries are exhausted', () async {
      final node = FallibleNode(
        failCount: 3,
        maxRetries: 2,
        useCustomFallback: true,
      );
      final result = await node.run(sharedStorage);
      expect(result, 'fallback');
    });

    test('should wait between retries', () async {
      const waitDuration = Duration(milliseconds: 50);
      final node = FallibleNode(
        failCount: 1,
        maxRetries: 2,
        wait: waitDuration,
      );
      final stopwatch = Stopwatch()..start();
      await node.run(sharedStorage);
      stopwatch.stop();
      expect(stopwatch.elapsed, greaterThanOrEqualTo(waitDuration));
    });

    test('should rethrow non-Exception errors immediately', () async {
      final node = FallibleNode(
        failCount: 1,
        maxRetries: 3,
        rethrowNonException: true,
      );
      await expectLater(
        () => node.run(sharedStorage),
        throwsA(isA<String>()),
      );
      // Fallback should not be reached, so attempts should be 1
      expect(node.attempts, 1);
    });
  });
}
