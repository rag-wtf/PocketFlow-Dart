import 'dart:math';

// The `>>` operator is used for its side effects of building the flow graph.
// The analyzer doesn't recognize this and flags it as an unnecessary statement.
// ignore_for_file: unnecessary_statements

import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A node that splits an array into chunks and processes them asynchronously
// in parallel. This now properly extends AsyncParallelBatchNode to match
// Python's behavior.
class AsyncArrayChunkNode extends AsyncParallelBatchNode<List<int>, int> {
  AsyncArrayChunkNode({this.chunkSize = 10});
  final int chunkSize;

  @override
  Future<List<List<int>>> prepAsync(Map<String, dynamic> sharedStorage) async {
    final array = sharedStorage['input_array'] as List<int>? ?? [];
    final chunks = <List<int>>[];
    for (var i = 0; i < array.length; i += chunkSize) {
      final end = min(i + chunkSize, array.length);
      chunks.add(array.sublist(i, end));
    }
    return chunks;
  }

  @override
  Future<int> execAsyncItem(List<int> chunk) async {
    await Future<void>.delayed(
      const Duration(milliseconds: 1),
    ); // Simulate async work
    if (chunk.isEmpty) {
      return 0;
    }
    return chunk.fold<int>(0, (pv, e) => pv + e);
  }

  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    sharedStorage['chunk_results'] = procResult as List<int>;
    return 'processed';
  }

  @override
  BaseNode createInstance() {
    return AsyncArrayChunkNode(chunkSize: chunkSize);
  }
}

// A node that sums the results of the chunk processing.
class AsyncSumReduceNode extends AsyncNode {
  @override
  Future<dynamic> prepAsync(Map<String, dynamic> sharedStorage) async {
    final chunkResults = sharedStorage['chunk_results'] as List<int>? ?? [];
    await Future<void>.delayed(
      const Duration(milliseconds: 10),
    ); // Simulate async processing
    final total = chunkResults.fold<int>(0, (sum, item) => sum + item);
    sharedStorage['total'] = total;
    return 'reduced';
  }

  @override
  BaseNode createInstance() {
    return AsyncSumReduceNode();
  }
}

void main() {
  group('AsyncBatchNode Parity Tests', () {
    test('Array chunking', () async {
      final sharedStorage = <String, dynamic>{
        'input_array': List<int>.generate(25, (i) => i), // [0, 1, ..., 24]
      };

      final chunkNode = AsyncArrayChunkNode();
      await chunkNode.run(sharedStorage);

      final results = sharedStorage['chunk_results'] as List<int>;
      // Sum of chunks [0-9], [10-19], [20-24]
      expect(results, equals([45, 145, 110]));
    });

    test('Async map-reduce sum', () async {
      // Test a complete async map-reduce pipeline that sums a large array:
      // 1. Map: Split array into chunks and sum each chunk asynchronously
      // 2. Reduce: Sum all the chunk sums asynchronously
      final array = List<int>.generate(100, (i) => i);
      final expectedSum = array.fold<int>(0, (sum, item) => sum + item); // 4950

      final sharedStorage = <String, dynamic>{
        'input_array': array,
      };

      // Create nodes
      final chunkNode = AsyncArrayChunkNode();
      final reduceNode = AsyncSumReduceNode();

      // Connect nodes
      chunkNode - 'processed' >> reduceNode;

      // Create and run pipeline
      final pipeline = AsyncFlow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(expectedSum));
    });

    test('Uneven chunks', () async {
      // Test that the async map-reduce works correctly with array lengths
      // that don't divide evenly by chunk_size
      final array = List<int>.generate(25, (i) => i);
      final expectedSum = array.fold<int>(0, (sum, item) => sum + item); // 300

      final sharedStorage = <String, dynamic>{
        'input_array': array,
      };

      final chunkNode = AsyncArrayChunkNode();
      final reduceNode = AsyncSumReduceNode();

      chunkNode - 'processed' >> reduceNode;
      final pipeline = AsyncFlow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(expectedSum));
    });

    test('Custom chunk size', () async {
      // Test that the async map-reduce works with different chunk sizes
      final array = List<int>.generate(100, (i) => i);
      final expectedSum = array.fold<int>(0, (sum, item) => sum + item);

      final sharedStorage = <String, dynamic>{
        'input_array': array,
      };

      // Use chunk_size=15 instead of default 10
      final chunkNode = AsyncArrayChunkNode(chunkSize: 15);
      final reduceNode = AsyncSumReduceNode();

      chunkNode - 'processed' >> reduceNode;
      final pipeline = AsyncFlow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(expectedSum));
    });

    test('Single element chunks', () async {
      // Test extreme case where chunk_size=1
      final array = List<int>.generate(5, (i) => i);
      final expectedSum = array.fold<int>(0, (sum, item) => sum + item);

      final sharedStorage = <String, dynamic>{
        'input_array': array,
      };

      final chunkNode = AsyncArrayChunkNode(chunkSize: 1);
      final reduceNode = AsyncSumReduceNode();

      chunkNode - 'processed' >> reduceNode;
      final pipeline = AsyncFlow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(expectedSum));
    });

    test('Empty array', () async {
      // Test edge case of empty input array
      final sharedStorage = <String, dynamic>{
        'input_array': <int>[],
      };

      final chunkNode = AsyncArrayChunkNode();
      final reduceNode = AsyncSumReduceNode();

      chunkNode - 'processed' >> reduceNode;
      final pipeline = AsyncFlow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(0));
    });

    test('Error handling', () async {
      // Test error handling in async batch processing
      // This matches Python's test_error_handling (commented out in Python)
      final sharedStorage = <String, dynamic>{
        'input_array': [1, 2, 3],
      };

      final errorNode = _ErrorAsyncBatchNode();
      expect(() => errorNode.run(sharedStorage), throwsException);
    });
  });
}

// Error node for testing error handling
class _ErrorAsyncBatchNode extends AsyncBatchNode<int, int> {
  @override
  Future<List<int>> prepAsync(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['input_array'] as List<int>;
  }

  @override
  Future<int> execAsyncItem(int item) async {
    if (item == 2) {
      throw Exception('Error processing item 2');
    }
    return item;
  }

  @override
  BaseNode createInstance() => _ErrorAsyncBatchNode();
}
