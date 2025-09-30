import 'dart:math';

import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A node that splits an array into chunks and sums each chunk.
class ArrayChunkNode extends BatchNode<List<int>, int> {
  ArrayChunkNode({this.chunkSize = 10});
  final int chunkSize;

  @override
  Future<List<List<int>>> prep(Map<String, dynamic> sharedStorage) async {
    final array = sharedStorage['input_array'] as List<int>? ?? [];
    final chunks = <List<int>>[];
    for (var i = 0; i < array.length; i += chunkSize) {
      final end = min(i + chunkSize, array.length);
      chunks.add(array.sublist(i, end));
    }
    return chunks;
  }

  @override
  Future<int> execItem(List<int> chunk) async {
    return chunk.fold<int>(0, (sum, item) => sum + item);
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic procResult,
  ) async {
    sharedStorage['chunk_results'] = procResult;
    return 'default';
  }

  @override
  BaseNode createInstance() => ArrayChunkNode(chunkSize: chunkSize);
}

// A node that sums the results of the chunk processing.
class SumReduceNode extends Node {
  @override
  Future<void> prep(Map<String, dynamic> sharedStorage) async {
    final chunkResults = sharedStorage['chunk_results'] as List<int>? ?? [];
    final total = chunkResults.fold<int>(0, (sum, item) => sum + item);
    sharedStorage['total'] = total;
  }

  @override
  BaseNode createInstance() => SumReduceNode();
}

void main() {
  group('BatchNode Parity Tests', () {
    test('Array chunking', () async {
      final sharedStorage = <String, dynamic>{
        'input_array': List<int>.generate(25, (i) => i), // [0, 1, ..., 24]
      };

      final chunkNode = ArrayChunkNode();
      await chunkNode.run(sharedStorage);

      final results = sharedStorage['chunk_results'] as List<int>;
      // Sum of chunks [0-9], [10-19], [20-24]
      expect(results, equals([45, 145, 110]));
    });

    Future<void> runMapReduceTest(
      List<int> array, {
      int chunkSize = 10,
    }) async {
      final expectedSum = array.isEmpty ? 0 : array.reduce((a, b) => a + b);

      final sharedStorage = <String, dynamic>{'input_array': array};

      final chunkNode = ArrayChunkNode(chunkSize: chunkSize);
      final reduceNode = SumReduceNode();

      // The `>>` operator is used for its side effects of building the flow
      // graph. The analyzer doesn't recognize this and flags it as an
      // unnecessary statement.
      // ignore: unnecessary_statements
      chunkNode >> reduceNode;

      final pipeline = Flow(start: chunkNode);
      await pipeline.run(sharedStorage);

      expect(sharedStorage['total'], equals(expectedSum));
    }

    test('Map-reduce sum', () async {
      await runMapReduceTest(List<int>.generate(100, (i) => i));
    });

    test('Uneven chunks', () async {
      await runMapReduceTest(List<int>.generate(25, (i) => i));
    });

    test('Custom chunk size', () async {
      await runMapReduceTest(List<int>.generate(100, (i) => i), chunkSize: 15);
    });

    test('Single element chunks', () async {
      await runMapReduceTest(List<int>.generate(5, (i) => i), chunkSize: 1);
    });

    test('Empty array', () async {
      await runMapReduceTest(<int>[]);
    });
  });
}
