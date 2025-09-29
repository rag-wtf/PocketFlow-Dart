import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A node that processes a list of numbers in parallel.
class AsyncParallelNumberProcessor extends Node {
  final Duration delay;

  AsyncParallelNumberProcessor({
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  Future<List<int>> prep(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['input_numbers'] as List<int>? ?? [];
  }

  @override
  Future<List<int>> exec(dynamic prepResult) async {
    final numbers = prepResult as List<int>;
    final futures = numbers.map((number) async {
      await Future<void>.delayed(delay);
      return number * 2;
    });
    return Future.wait(futures);
  }

  @override
  Future<String> post(
    Map<String, dynamic> sharedStorage,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    sharedStorage['processed_numbers'] = execResult;
    return "processed";
  }

  @override
  BaseNode createInstance() => AsyncParallelNumberProcessor(delay: delay);
}

void main() {
  group('AsyncParallelBatchNode Parity Tests', () {
    test('Parallel processing', () async {
      final sharedStorage = <String, dynamic>{
        'input_numbers': List<int>.generate(5, (i) => i),
      };

      final processor = AsyncParallelNumberProcessor(
        delay: const Duration(milliseconds: 100),
      );

      final stopwatch = Stopwatch()..start();
      await processor.run(sharedStorage);
      stopwatch.stop();

      final expected = [0, 2, 4, 6, 8];
      expect(sharedStorage['processed_numbers'], equals(expected));

      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Empty input', () async {
      final sharedStorage = <String, dynamic>{
        'input_numbers': <int>[],
      };

      final processor = AsyncParallelNumberProcessor();
      await processor.run(sharedStorage);

      expect(sharedStorage['processed_numbers'], isEmpty);
    });

    test('Single item', () async {
      final sharedStorage = <String, dynamic>{
        'input_numbers': [42],
      };

      final processor = AsyncParallelNumberProcessor();
      await processor.run(sharedStorage);

      expect(sharedStorage['processed_numbers'], equals([84]));
    });

    test('Large batch', () async {
      const inputSize = 100;
      final sharedStorage = <String, dynamic>{
        'input_numbers': List<int>.generate(inputSize, (i) => i),
      };

      final processor = AsyncParallelNumberProcessor(
        delay: const Duration(milliseconds: 10),
      );
      await processor.run(sharedStorage);

      final expected = List<int>.generate(inputSize, (i) => i * 2);
      expect(sharedStorage['processed_numbers'], equals(expected));
    });

    test('Error handling', () {
      final processor = _ErrorProcessor();
      final sharedStorage = <String, dynamic>{
        'input_numbers': [1, 2, 3],
      };
      expect(() => processor.run(sharedStorage), throwsException);
    });

    test('Concurrent execution', () async {
      final executionOrder = <int>[];
      final processor = _OrderTrackingProcessor(executionOrder);

      final sharedStorage = <String, dynamic>{
        'input_numbers': [0, 1, 2, 3],
      };

      await processor.run(sharedStorage);

      // Odd numbers (1, 3) should finish before even numbers (0, 2)
      expect(executionOrder.indexOf(1), lessThan(executionOrder.indexOf(0)));
      expect(executionOrder.indexOf(3), lessThan(executionOrder.indexOf(2)));
    });
  });
}

class _ErrorProcessor extends Node {
  @override
  Future<List<int>> prep(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['input_numbers'] as List<int>;
  }

  @override
  Future<List<int>> exec(dynamic prepResult) {
    final numbers = prepResult as List<int>;
    final futures = numbers.map((number) async {
      if (number == 2) {
        throw Exception('Error processing item 2');
      }
      return number;
    });
    return Future.wait(futures);
  }

  @override
  BaseNode createInstance() => _ErrorProcessor();
}

class _OrderTrackingProcessor extends Node {
  final List<int> executionOrder;
  _OrderTrackingProcessor(this.executionOrder);

  @override
  Future<List<int>> prep(Map<String, dynamic> sharedStorage) async {
    return sharedStorage['input_numbers'] as List<int>;
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    final numbers = prepResult as List<int>;
    final futures = numbers.map((item) async {
      final delay = Duration(milliseconds: item % 2 == 0 ? 100 : 50);
      await Future<void>.delayed(delay);
      executionOrder.add(item);
      return item;
    });
    return Future.wait(futures);
  }

  @override
  BaseNode createInstance() => _OrderTrackingProcessor(executionOrder);
}
