// Tests for AsyncBatchFlow parity with Python implementation
// These tests verify that Dart's AsyncBatchFlow matches Python's behavior
// of running the flow multiple times with different parameters.

import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Test node that processes data based on params
class AsyncDataProcessNode extends AsyncNode {
  @override
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    final key = params['key'] as String;
    final data = (shared['input_data'] as Map<String, dynamic>)[key];
    if (!shared.containsKey('results')) {
      shared['results'] = <String, dynamic>{};
    }
    (shared['results'] as Map<String, dynamic>)[key] = data;
    return data;
  }

  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final key = params['key'] as String;
    (shared['results'] as Map<String, dynamic>)[key] = (prepResult as int) * 2;
    return 'processed';
  }

  @override
  BaseNode createInstance() {
    return AsyncDataProcessNode();
  }
}

// Test node that throws errors for specific keys
class AsyncErrorNode extends AsyncNode {
  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    final key = params['key'] as String;
    if (key == 'error_key') {
      throw Exception('Async error processing key: $key');
    }
    return 'processed';
  }

  @override
  BaseNode createInstance() {
    return AsyncErrorNode();
  }
}

// Inner node for nested flow test
class AsyncInnerNode extends AsyncNode {
  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    final key = params['key'] as String;
    if (!shared.containsKey('intermediate_results')) {
      shared['intermediate_results'] = <String, dynamic>{};
    }
    final inputData = shared['input_data'] as Map<String, dynamic>;
    (shared['intermediate_results'] as Map<String, dynamic>)[key] =
        (inputData[key] as int) + 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'next';
  }

  @override
  BaseNode createInstance() {
    return AsyncInnerNode();
  }
}

// Outer node for nested flow test
class AsyncOuterNode extends AsyncNode {
  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    final key = params['key'] as String;
    if (!shared.containsKey('results')) {
      shared['results'] = <String, dynamic>{};
    }
    final intermediateResults =
        shared['intermediate_results'] as Map<String, dynamic>;
    (shared['results'] as Map<String, dynamic>)[key] =
        (intermediateResults[key] as int) * 2;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'done';
  }

  @override
  BaseNode createInstance() {
    return AsyncOuterNode();
  }
}

// Custom param node for testing parameter merging
class CustomParamAsyncNode extends AsyncNode {
  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    final key = params['key'] as String;
    final multiplier = params['multiplier'] as int? ?? 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!shared.containsKey('results')) {
      shared['results'] = <String, dynamic>{};
    }
    final inputData = shared['input_data'] as Map<String, dynamic>;
    (shared['results'] as Map<String, dynamic>)[key] =
        (inputData[key] as int) * multiplier;
    return 'done';
  }

  @override
  BaseNode createInstance() {
    return CustomParamAsyncNode();
  }
}

void main() {
  group('AsyncBatchFlow Parity Tests', () {
    test('basic async batch processing with multiple keys', () async {
      final flow = _SimpleTestAsyncBatchFlow(
        start: AsyncDataProcessNode(),
      );

      final shared = <String, dynamic>{
        'input_data': {
          'a': 1,
          'b': 2,
          'c': 3,
        },
      };

      await flow.runAsync(shared);

      final expectedResults = {
        'a': 2, // 1 * 2
        'b': 4, // 2 * 2
        'c': 6, // 3 * 2
      };
      expect(shared['results'], equals(expectedResults));
    });

    test('empty async batch', () async {
      final flow = _EmptyTestAsyncBatchFlow(
        start: AsyncDataProcessNode(),
      );

      final shared = <String, dynamic>{
        'input_data': <String, dynamic>{},
      };

      await flow.runAsync(shared);

      expect(shared['results'] ?? <String, dynamic>{}, equals({}));
    });

    test('async error handling', () async {
      final flow = _ErrorTestAsyncBatchFlow(
        start: AsyncErrorNode(),
      );

      final shared = <String, dynamic>{
        'input_data': {
          'normal_key': 1,
          'error_key': 2,
          'another_key': 3,
        },
      };

      expect(
        () => flow.runAsync(shared),
        throwsA(isA<Exception>()),
      );
    });

    test('nested async flow', () async {
      final innerNode = AsyncInnerNode();
      final outerNode = AsyncOuterNode();
      // Connect innerNode to outerNode with 'next' action
      innerNode.next(outerNode, action: 'next');

      final flow = _NestedAsyncBatchFlow(start: innerNode);

      final shared = <String, dynamic>{
        'input_data': {
          'x': 1,
          'y': 2,
        },
      };

      await flow.runAsync(shared);

      final expectedResults = {
        'x': 4, // (1 + 1) * 2
        'y': 6, // (2 + 1) * 2
      };
      expect(shared['results'], equals(expectedResults));
    });

    test('custom async parameters', () async {
      final flow = _CustomParamAsyncBatchFlow(
        start: CustomParamAsyncNode(),
      );

      final shared = <String, dynamic>{
        'input_data': {
          'a': 1,
          'b': 2,
          'c': 3,
        },
      };

      await flow.runAsync(shared);

      final expectedResults = {
        'a': 1 * 1, // first item, multiplier = 1
        'b': 2 * 2, // second item, multiplier = 2
        'c': 3 * 3, // third item, multiplier = 3
      };
      expect(shared['results'], equals(expectedResults));
    });
  });
}

// Helper classes for testing

class _SimpleTestAsyncBatchFlow extends AsyncBatchFlow {
  _SimpleTestAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final inputData = shared['input_data'] as Map<String, dynamic>;
    return inputData.keys.map((k) => {'key': k}).toList();
  }
}

class _EmptyTestAsyncBatchFlow extends AsyncBatchFlow {
  _EmptyTestAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final inputData = shared['input_data'] as Map<String, dynamic>;
    return inputData.keys.map((k) => {'key': k}).toList();
  }
}

class _ErrorTestAsyncBatchFlow extends AsyncBatchFlow {
  _ErrorTestAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final inputData = shared['input_data'] as Map<String, dynamic>;
    return inputData.keys.map((k) => {'key': k}).toList();
  }
}

class _NestedAsyncBatchFlow extends AsyncBatchFlow {
  _NestedAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final inputData = shared['input_data'] as Map<String, dynamic>;
    return inputData.keys.map((k) => {'key': k}).toList();
  }
}

class _CustomParamAsyncBatchFlow extends AsyncBatchFlow {
  _CustomParamAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final inputData = shared['input_data'] as Map<String, dynamic>;
    var i = 0;
    return inputData.keys.map((k) {
      i++;
      return {
        'key': k,
        'multiplier': i,
      };
    }).toList();
  }
}
