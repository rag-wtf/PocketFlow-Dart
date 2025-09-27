import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncParallelBatchFlow', () {
    test('should process a batch of inputs in parallel', () async {
      final flow = AsyncParallelBatchFlow<int, int>([
        AsyncNode((int x) async => x * 2),
        AsyncNode((int x) async => x * 3),
      ]);

      final result = await flow.call([1, 2, 3]);
      expect(result, [
        [2, 3],
        [4, 6],
        [6, 9]
      ]);
    });
  });
}