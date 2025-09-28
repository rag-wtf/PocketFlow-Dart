import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncParallelBatchFlow', () {
    test('should process a batch of inputs in parallel', () async {
      final flow = AsyncParallelBatchFlow<int, int>([
        AsyncNode(
          (dynamic r) async =>
              ((r as Map<String, dynamic>)['input'] as int) * 2,
        ),
        AsyncNode(
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
  });
}
