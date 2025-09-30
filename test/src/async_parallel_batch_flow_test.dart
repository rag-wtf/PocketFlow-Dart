// NOTE: This file tests the OLD AsyncParallelBatchFlow API which has been
// moved to ParallelNodeBatchFlow. The new AsyncParallelBatchFlow matches
// Python's behavior and is tested in the parity tests.
//
// These tests are kept for backwards compatibility testing of
// ParallelNodeBatchFlow.

import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('ParallelNodeBatchFlow (old AsyncParallelBatchFlow API)', () {
    test('should process a batch of inputs in parallel', () async {
      final flow = ParallelNodeBatchFlow<int, int>([
        SimpleAsyncNode(
          (dynamic r) async =>
              ((r as Map<String, dynamic>)['input'] as int) * 2,
        ),
        SimpleAsyncNode(
          (dynamic r) async =>
              ((r as Map<String, dynamic>)['input'] as int) * 3,
        ),
      ]);

      final result = await flow.call([1, 2, 3]);
      expect(result, [
        [2, 3],
        [4, 6],
        [6, 9],
      ]);
    });

    test('should handle an empty input list', () async {
      final flow = ParallelNodeBatchFlow<int, int>([
        SimpleAsyncNode((dynamic r) async => 1),
      ]);
      final result = await flow.call([]);
      expect(result, isEmpty);
    });

    test('constructor should throw ArgumentError if nodes list is empty', () {
      expect(
        () => ParallelNodeBatchFlow<int, int>([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('run should throw ArgumentError if input parameter is missing', () {
      final flow = ParallelNodeBatchFlow<int, int>([
        SimpleAsyncNode((dynamic r) async => 1),
      ]);
      // No 'input' in params
      expect(
        () => flow.run({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('run should throw ArgumentError if input is not a List', () {
      final flow = ParallelNodeBatchFlow<int, int>([
        SimpleAsyncNode((dynamic r) async => 1),
      ]);
      flow.params['input'] = 'not a list';
      expect(
        () => flow.run({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('clone should create a deep copy of the flow', () {
      final node = SimpleAsyncNode((dynamic r) async => 1);
      final flow = ParallelNodeBatchFlow<int, int>([node]);

      final clonedFlow = flow.clone();

      expect(clonedFlow, isA<ParallelNodeBatchFlow<int, int>>());
      expect(clonedFlow, isNot(same(flow)));
    });

    test('should propagate errors from nodes', () async {
      final flow = ParallelNodeBatchFlow<int, int>([
        SimpleAsyncNode((dynamic r) async => 1),
        SimpleAsyncNode((dynamic r) async => throw Exception('Node error')),
      ]);

      expect(
        () => flow.call([1]),
        throwsA(isA<Exception>()),
      );
    });
  });
}
