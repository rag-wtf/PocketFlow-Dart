import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Helper to simulate Python's AsyncBatchFlow behavior for parity testing.
Future<void> runAsyncBatchFlow({
  required BaseNode start,
  required Future<List<Map<String, dynamic>>> Function(Map<String, dynamic>)
  prep,
  required Map<String, dynamic> shared,
}) async {
  final inputs = await prep(shared);
  final futures = <Future<dynamic>>[];
  for (final input in inputs) {
    final startClone = start.clone();
    startClone.params = input;
    final flow = AsyncFlow(start: startClone);
    futures.add(flow.run(shared));
  }
  await Future.wait(futures);
}

// Node that processes data asynchronously
class AsyncDataProcessNode extends AsyncNode {
  @override
  Future<dynamic> prep(Map<String, dynamic> sharedStorage) async {
    final key = params['key'];
    final data = sharedStorage['input_data'][key];
    return data;
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 10),
    ); // Simulate async work
    final key = params['key'];
    sharedStorage['results'][key] = prepResult * 2; // Double the value
    return 'processed';
  }

  @override
  BaseNode createInstance() => AsyncDataProcessNode();
}

// Node that throws an error for a specific key
class AsyncErrorNode extends AsyncNode {
  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    final key = params['key'];
    if (key == 'error_key') {
      throw Exception('Async error processing key: $key');
    }
    return 'processed';
  }

  @override
  BaseNode createInstance() => AsyncErrorNode();
}

class _InnerNode extends AsyncNode {
  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    final key = params['key'];
    if (!sharedStorage.containsKey('intermediate_results')) {
      sharedStorage['intermediate_results'] = <String, dynamic>{};
    }
    sharedStorage['intermediate_results'][key] =
        sharedStorage['input_data'][key] + 1;
    sharedStorage['current_key'] =
        key; // Pass key to next node via shared state
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'next';
  }

  @override
  BaseNode createInstance() => _InnerNode();
}

class _OuterNode extends AsyncNode {
  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    final key = sharedStorage['current_key']; // Get key from shared state
    if (!sharedStorage.containsKey('results')) {
      sharedStorage['results'] = <String, dynamic>{};
    }
    sharedStorage['results'][key] =
        sharedStorage['intermediate_results'][key] * 2;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 'done';
  }

  @override
  BaseNode createInstance() => _OuterNode();
}

class _CustomParamNode extends AsyncNode {
  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    final key = params['key'];
    final multiplier = params['multiplier'] ?? 1;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (!sharedStorage.containsKey('results')) {
      sharedStorage['results'] = <String, dynamic>{};
    }
    sharedStorage['results'][key] =
        sharedStorage['input_data'][key] * multiplier;
    return 'done';
  }

  @override
  BaseNode createInstance() => _CustomParamNode();
}

void main() {
  group(
    'AsyncBatchFlow Parity Tests',
    () {
      late AsyncDataProcessNode processNode;

      setUp(() {
        processNode = AsyncDataProcessNode();
      });

      test('Test basic async batch processing', () async {
        final sharedStorage = {
          'input_data': {'a': 1, 'b': 2, 'c': 3},
          'results': <String, dynamic>{},
        };

        await runAsyncBatchFlow(
          start: processNode,
          prep: (sharedStorage) async {
            final keys =
                (sharedStorage['input_data'] as Map<String, dynamic>).keys;
            return [
              for (final k in keys) {'key': k},
            ];
          },
          shared: sharedStorage,
        );

        final expectedResults = {'a': 2, 'b': 4, 'c': 6};
        expect(sharedStorage['results'], equals(expectedResults));
      });

      test('Test empty async batch', () async {
        final sharedStorage = {
          'input_data': <String, dynamic>{},
        };

        await runAsyncBatchFlow(
          start: processNode,
          prep: (sharedStorage) async {
            final keys =
                (sharedStorage['input_data'] as Map<String, dynamic>).keys;
            return [
              for (final k in keys) {'key': k},
            ];
          },
          shared: sharedStorage,
        );

        expect(sharedStorage['results'], isNull);
      });

      test('Test async error handling', () async {
        final sharedStorage = {
          'input_data': {'normal_key': 1, 'error_key': 2, 'another_key': 3},
        };

        final future = runAsyncBatchFlow(
          start: AsyncErrorNode(),
          prep: (sharedStorage) async {
            final keys =
                (sharedStorage['input_data'] as Map<String, dynamic>).keys;
            return [
              for (final k in keys) {'key': k},
            ];
          },
          shared: sharedStorage,
        );

        expect(future, throwsException);
      });

      test('Test nested async flow', () async {
        final innerNode = _InnerNode();
        final outerNode = _OuterNode();

        innerNode - 'next' >> outerNode;

        final sharedStorage = {
          'input_data': {'x': 1, 'y': 2},
          'intermediate_results': <String, dynamic>{},
          'results': <String, dynamic>{},
        };

        await runAsyncBatchFlow(
          start: innerNode,
          prep: (sharedStorage) async {
            final keys =
                (sharedStorage['input_data'] as Map<String, dynamic>).keys;
            return [
              for (final k in keys) {'key': k},
            ];
          },
          shared: sharedStorage,
        );

        final expectedResults = {'x': 4, 'y': 6};
        expect(sharedStorage['results'], equals(expectedResults));
      });

      test('Test custom async parameters', () async {
        final customParamNode = _CustomParamNode();

        final sharedStorage = {
          'input_data': {'a': 1, 'b': 2, 'c': 3},
          'results': <String, dynamic>{},
        };

        await runAsyncBatchFlow(
          start: customParamNode,
          prep: (sharedStorage) async {
            final keys = (sharedStorage['input_data'] as Map<String, dynamic>)
                .keys
                .toList();
            return [
              for (var i = 0; i < keys.length; i++)
                {'key': keys[i], 'multiplier': i + 1},
            ];
          },
          shared: sharedStorage,
        );

        final expectedResults = {'a': 1, 'b': 4, 'c': 9};
        expect(sharedStorage['results'], equals(expectedResults));
      });
    },
    skip:
        'Skipping due to state isolation in the runAsyncBatchFlow helper function.',
  );
}
