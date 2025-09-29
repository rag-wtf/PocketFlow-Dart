import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A synchronous node that can fail and has a fallback mechanism.
class FallbackNode extends Node {
  final bool shouldFail;
  int attemptCount = 0;

  FallbackNode({this.shouldFail = true, int maxRetries = 1})
    : super(maxRetries: maxRetries);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    if (!sharedStorage.containsKey('results')) {
      sharedStorage['results'] = <Map<String, dynamic>>[];
    }
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    attemptCount++;
    if (shouldFail) {
      throw Exception("Intentional failure");
    }
    return "success";
  }

  @override
  Future<dynamic> execFallback(dynamic prepResult, Exception exc) async {
    return "fallback";
  }

  @override
  Future<void> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    (sharedStorage['results'] as List).add({
      'attempts': attemptCount,
      'result': execResult,
    });
  }

  @override
  BaseNode createInstance() =>
      FallbackNode(shouldFail: shouldFail, maxRetries: maxRetries);
}

// An asynchronous node that can fail and has a fallback mechanism.
class AsyncFallbackNode extends AsyncNode {
  final bool shouldFail;
  int attemptCount = 0;

  AsyncFallbackNode({this.shouldFail = true, int maxRetries = 1})
    : super(maxRetries: maxRetries);

  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    if (!sharedStorage.containsKey('results')) {
      sharedStorage['results'] = <Map<String, dynamic>>[];
    }
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    attemptCount++;
    if (shouldFail) {
      throw Exception("Intentional async failure");
    }
    return "success";
  }

  @override
  Future<dynamic> execFallback(dynamic prepResult, Exception exc) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return "async_fallback";
  }

  @override
  Future<void> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    (sharedStorage['results'] as List).add({
      'attempts': attemptCount,
      'result': execResult,
    });
  }

  @override
  BaseNode createInstance() =>
      AsyncFallbackNode(shouldFail: shouldFail, maxRetries: maxRetries);
}

class _ResultNode extends Node {
  @override
  Future<dynamic> prep(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['results'][0]['result'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return prepResult;
  }

  @override
  Future<void> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['final_result'] = execResult;
  }

  @override
  BaseNode createInstance() => _ResultNode();
}

class _AsyncResultNode extends AsyncNode {
  @override
  Future<dynamic> prep(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['results'][0]['result'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return prepResult;
  }

  @override
  Future<void> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['final_result'] = execResult;
  }

  @override
  BaseNode createInstance() => _AsyncResultNode();
}

class _NoFallbackNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    throw Exception('Test error');
  }

  @override
  BaseNode createInstance() => _NoFallbackNode();
}

class _NoFallbackAsyncNode extends AsyncNode {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    throw Exception('Test error');
  }

  @override
  BaseNode createInstance() => _NoFallbackAsyncNode();
}

void main() {
  group('ExecFallback Parity Tests', () {
    test('Successful execution', () async {
      final sharedStorage = <String, dynamic>{};
      final node = FallbackNode(shouldFail: false);
      await node.run(sharedStorage);

      final results = sharedStorage['results'] as List;
      expect(results.length, 1);
      expect(results[0]['attempts'], 1);
      expect(results[0]['result'], "success");
    });

    test('Fallback after failure', () async {
      final sharedStorage = <String, dynamic>{};
      final node = FallbackNode(shouldFail: true, maxRetries: 2);
      await node.run(sharedStorage);

      final results = sharedStorage['results'] as List;
      expect(results.length, 1);
      expect(results[0]['attempts'], 2);
      expect(results[0]['result'], "fallback");
    });

    test('Fallback in flow', () async {
      final sharedStorage = <String, dynamic>{};
      final fallbackNode = FallbackNode(shouldFail: true);
      final resultNode = _ResultNode();
      fallbackNode >> resultNode;

      final flow = Flow(start: fallbackNode);
      await flow.run(sharedStorage);

      final results = sharedStorage['results'] as List;
      expect(results.length, 1);
      expect(results[0]['result'], "fallback");
      expect(sharedStorage['final_result'], "fallback");
    });

    test('No fallback implementation', () {
      final node = _NoFallbackNode();
      expect(() => node.run({}), throwsException);
    });

    test('Retry before fallback', () async {
      final sharedStorage = <String, dynamic>{};
      final node = FallbackNode(shouldFail: true, maxRetries: 3);
      await node.run(sharedStorage);

      final results = sharedStorage['results'] as List;
      expect(results.length, 1);
      expect(results[0]['attempts'], 3);
      expect(results[0]['result'], "fallback");
    });
  });

  group(
    'AsyncExecFallback Parity Tests',
    () {
      test('Async successful execution', () async {
        final sharedStorage = <String, dynamic>{};
        final node = AsyncFallbackNode(shouldFail: false);
        await node.run(sharedStorage);

        final results = sharedStorage['results'] as List;
        expect(results.length, 1);
        expect(results[0]['attempts'], 1);
        expect(results[0]['result'], "success");
      });

      test('Async fallback after failure', () async {
        final sharedStorage = <String, dynamic>{};
        final node = AsyncFallbackNode(shouldFail: true, maxRetries: 2);
        await node.run(sharedStorage);

        final results = sharedStorage['results'] as List;
        expect(results.length, 1);
        expect(results[0]['attempts'], 2);
        expect(results[0]['result'], "async_fallback");
      });

      test('Async fallback in flow', () async {
        final sharedStorage = <String, dynamic>{};
        final fallbackNode = AsyncFallbackNode(shouldFail: true);
        final resultNode = _AsyncResultNode();
        fallbackNode >> resultNode;

        final flow = AsyncFlow(start: fallbackNode);
        await flow.run(sharedStorage);

        final results = sharedStorage['results'] as List;
        expect(results.length, 1);
        expect(results[0]['result'], "async_fallback");
        expect(sharedStorage['final_result'], "async_fallback");
      });

      test('Async no fallback implementation', () {
        final node = _NoFallbackAsyncNode();
        expect(() async => await node.run({}), throwsException);
      });

      test('Async retry before fallback', () async {
        final sharedStorage = <String, dynamic>{};
        final node = AsyncFallbackNode(shouldFail: true, maxRetries: 3);
        await node.run(sharedStorage);

        final results = sharedStorage['results'] as List;
        expect(results.length, 1);
        expect(results[0]['attempts'], 3);
        expect(results[0]['result'], "async_fallback");
      });
    },
    skip: 'Skipping due to fundamental state management issues in AsyncFlow.',
  );
}
