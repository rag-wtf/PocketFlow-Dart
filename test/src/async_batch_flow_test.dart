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

void main() {
  group('AsyncBatchFlow', () {
    test('basic async batch processing with multiple keys', () async {
      // Create a custom AsyncBatchFlow subclass
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
      final flow = _SimpleTestAsyncBatchFlow(
        start: AsyncDataProcessNode(),
      );

      final shared = <String, dynamic>{
        'input_data': <String, dynamic>{},
      };

      await flow.runAsync(shared);

      expect(
        shared['results'] ?? <String, dynamic>{},
        equals(<String, dynamic>{}),
      );
    });

    test('clone should create a deep copy of the flow', () {
      final node = AsyncDataProcessNode();
      final flow = AsyncBatchFlow(start: node)
        ..name = 'TestFlow'
        ..params['value'] = 42;

      final clonedFlow = flow.clone();

      expect(clonedFlow, isA<AsyncBatchFlow>());
      expect(clonedFlow.name, equals('TestFlow'));
      expect(clonedFlow.params['value'], equals(42));
      expect(clonedFlow, isNot(same(flow)));
    });
  });

  test('should handle null from prepAsync', () async {
    final flow = _NullPrepAsyncBatchFlow(start: _MyNode());
    final shared = <String, dynamic>{};
    await flow.runAsync(shared);
    expect(shared['post_called'], isTrue);
  });
}

class _MyNode extends AsyncNode {
  @override
  Future<void> execAsync(dynamic prepResult) async {}
}

class _NullPrepAsyncBatchFlow extends AsyncBatchFlow {
  _NullPrepAsyncBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>?> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    return null;
  }

  @override
  Future<void> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['post_called'] = true;
  }

  @override
  _NullPrepAsyncBatchFlow clone() {
    return super.copy(_NullPrepAsyncBatchFlow.new);
  }
}

// Helper class for testing
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
