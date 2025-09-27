import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncNode', () {
    test('should execute an asynchronous function', () async {
      final node = AsyncNode<int, int>(
        (int x) async => x * 2,
      );
      final result = await node.call(2);
      expect(result, 4);
    });
  });
}