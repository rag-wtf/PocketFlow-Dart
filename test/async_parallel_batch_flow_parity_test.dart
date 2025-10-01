// Tests for AsyncParallelBatchFlow parity with Python implementation
// These tests verify that Dart's AsyncParallelBatchFlow matches Python's
// behavior of running the flow multiple times in parallel with different
// parameters.

// The `>>` operator is used for its side effects of building the flow graph.
// The analyzer doesn't recognize this and flags it as an unnecessary statement.
// ignore_for_file: unnecessary_statements

import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Processes a batch of numbers asynchronously and in parallel.
class AsyncParallelNumberProcessor extends AsyncParallelBatchNode<int, int> {
  AsyncParallelNumberProcessor({
    this.delay = const Duration(milliseconds: 100),
  });
  final Duration delay;

  @override
  Future<List<int>> prepAsync(Map<String, dynamic> sharedStorage) async {
    final batchId = params['batch_id'] as int;
    final batches = sharedStorage['batches'] as List<List<int>>;
    return batches[batchId];
  }

  @override
  Future<int> execAsyncItem(int number) async {
    await Future<void>.delayed(delay);
    return number * 2;
  }

  @override
  Future<String> postAsync(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    if (!sharedStorage.containsKey('processed_numbers')) {
      sharedStorage['processed_numbers'] = <int, List<int>>{};
    }
    final batchId = params['batch_id'] as int;
    (sharedStorage['processed_numbers'] as Map<int, List<int>>)[batchId] =
        execResult as List<int>;
    return 'processed';
  }

  @override
  BaseNode createInstance() => AsyncParallelNumberProcessor(delay: delay);
}

// Aggregates the results from all batches.
class AsyncAggregatorNode extends AsyncNode {
  @override
  Future<List<int>> prepAsync(Map<String, dynamic> sharedStorage) async {
    final allResults = <int>[];
    final processed =
        sharedStorage['processed_numbers'] as Map<int, List<int>>? ?? {};
    final sortedKeys = processed.keys.toList()..sort();
    for (final key in sortedKeys) {
      allResults.addAll(processed[key]!);
    }
    return allResults;
  }

  @override
  Future<int> execAsync(dynamic prepResult) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return (prepResult as List<int>).fold<int>(
      0,
      (int sum, int item) => sum + item,
    );
  }

  @override
  Future<String> postAsync(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['total'] = execResult;
    return 'aggregated';
  }

  @override
  BaseNode createInstance() => AsyncAggregatorNode();
}

// Custom AsyncParallelBatchFlow for testing
class TestParallelBatchFlow extends AsyncParallelBatchFlow {
  TestParallelBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final batches = shared['batches'] as List<List<int>>;
    return [
      for (var i = 0; i < batches.length; i++) {'batch_id': i},
    ];
  }

  @override
  TestParallelBatchFlow clone() {
    return super.copy(TestParallelBatchFlow.new);
  }
}

class ErrorProcessor extends AsyncParallelNumberProcessor {
  ErrorProcessor({super.delay});

  @override
  Future<int> execAsyncItem(int item) async {
    if (item == 2) {
      throw Exception('Error processing item 2');
    }
    return item;
  }

  @override
  BaseNode createInstance() => ErrorProcessor(delay: delay);
}

class ErrorBatchFlow extends AsyncParallelBatchFlow {
  ErrorBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final batches = shared['batches'] as List<List<int>>;
    return [
      for (var i = 0; i < batches.length; i++) {'batch_id': i},
    ];
  }

  @override
  ErrorBatchFlow clone() {
    return super.copy(ErrorBatchFlow.new);
  }
}

class VaryingBatchFlow extends AsyncParallelBatchFlow {
  VaryingBatchFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    final batches = shared['batches'] as List<List<int>>;
    return [
      for (var i = 0; i < batches.length; i++) {'batch_id': i},
    ];
  }

  @override
  VaryingBatchFlow clone() {
    return super.copy(VaryingBatchFlow.new);
  }
}

void main() {
  group('AsyncParallelBatchFlow Parity Tests', () {
    test('Parallel batch flow', () async {
      final sharedStorage = <String, dynamic>{
        'batches': [
          [1, 2, 3], // batch_id: 0
          [4, 5, 6], // batch_id: 1
          [7, 8, 9], // batch_id: 2
        ],
      };

      final processor = AsyncParallelNumberProcessor();
      final aggregator = AsyncAggregatorNode();

      processor - 'processed' >> aggregator;
      final flow = TestParallelBatchFlow(start: processor);

      final stopwatch = Stopwatch()..start();
      await flow.runAsync(sharedStorage);
      stopwatch.stop();

      // Verify each batch was processed correctly
      final expectedBatchResults = {
        0: [2, 4, 6], // [1,2,3] * 2
        1: [8, 10, 12], // [4,5,6] * 2
        2: [14, 16, 18], // [7,8,9] * 2
      };
      expect(
        sharedStorage['processed_numbers'],
        equals(expectedBatchResults),
      );

      // Verify total
      final expectedTotal = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
      ].fold<int>(0, (sum, n) => sum + (n * 2));
      expect(sharedStorage['total'], equals(expectedTotal));

      // Verify parallel execution (should be < 200ms for 3 batches)
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Error handling in parallel batch flow', () async {
      final sharedStorage = <String, dynamic>{
        'batches': [
          [1, 2, 3], // Contains error-triggering value
          [4, 5, 6],
        ],
      };

      final processor = ErrorProcessor();
      final flow = ErrorBatchFlow(start: processor);

      expect(
        () => flow.runAsync(sharedStorage),
        throwsException,
      );
    });

    test('Multiple batch sizes', () async {
      final sharedStorage = <String, dynamic>{
        'batches': [
          [1], // batch_id: 0
          [2, 3, 4], // batch_id: 1
          [5, 6], // batch_id: 2
          [7, 8, 9, 10], // batch_id: 3
        ],
      };

      final processor = AsyncParallelNumberProcessor(
        delay: const Duration(milliseconds: 50),
      );
      final aggregator = AsyncAggregatorNode();

      processor - 'processed' >> aggregator;
      final flow = VaryingBatchFlow(start: processor);

      await flow.runAsync(sharedStorage);

      // Verify each batch was processed correctly
      final expectedBatchResults = {
        0: [2], // [1] * 2
        1: [4, 6, 8], // [2,3,4] * 2
        2: [10, 12], // [5,6] * 2
        3: [14, 16, 18, 20], // [7,8,9,10] * 2
      };
      expect(
        sharedStorage['processed_numbers'],
        equals(expectedBatchResults),
      );

      // Verify total
      final expectedTotal = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
      ].fold<int>(0, (sum, n) => sum + (n * 2));
      expect(sharedStorage['total'], equals(expectedTotal));
    });
  });

  test('Handles null from prepAsync', () async {
    // A flow where prepAsync returns null
    final flow = NullPrepFlow(start: AsyncAggregatorNode());
    final shared = <String, dynamic>{};

    // Should run without errors
    await flow.runAsync(shared);

    // No processing should happen, total should not be set
    expect(shared.containsKey('total'), isFalse);
  });

  test('Clones the flow correctly', () async {
    final processor = AsyncParallelNumberProcessor();
    final aggregator = AsyncAggregatorNode();
    processor - 'processed' >> aggregator;

    final originalFlow = TestParallelBatchFlow(start: processor);

    // Clone the flow
    final clonedFlow = originalFlow.clone();

    expect(clonedFlow, isNot(same(originalFlow)));
    expect(clonedFlow, isA<TestParallelBatchFlow>());

    final shared = <String, dynamic>{
      'batches': [
        [1, 2],
      ],
    };

    // Run the cloned flow
    await clonedFlow.runAsync(shared);

    // Verify the result
    final expectedTotal = [1, 2].fold<int>(0, (sum, n) => sum + (n * 2));
    expect(shared['total'], equals(expectedTotal));
  });

  test('Base AsyncParallelBatchFlow can be cloned', () {
    final flow = AsyncParallelBatchFlow(start: AsyncAggregatorNode());
    final cloned = flow.clone();
    expect(cloned, isNot(same(flow)));
    expect(cloned, isA<AsyncParallelBatchFlow>());
  });
}

// A flow that returns null from prepAsync to test null safety.
class NullPrepFlow extends AsyncParallelBatchFlow {
  NullPrepFlow({super.start});

  @override
  Future<List<Map<String, dynamic>>?> prepAsync(
    Map<String, dynamic> shared,
  ) async {
    return null;
  }

  @override
  NullPrepFlow clone() {
    return super.copy(NullPrepFlow.new);
  }
}
