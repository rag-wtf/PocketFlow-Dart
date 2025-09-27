import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A helper async function for testing.
Future<int> asyncAdd(int a, int b) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return a + b;
}

void main() {
  group('AsyncFlow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('should execute a simple async flow', () async {
      // This test is expected to fail because AsyncFlow and AsyncNode are not yet implemented.
      final addNode1 = AsyncNode((Map<String, dynamic> storage) async {
        storage['result'] = await asyncAdd(10, 12);
        return storage;
      });
      final addNode2 = AsyncNode((Map<String, dynamic> storage) async {
        storage['result'] = await asyncAdd(5, 5);
        return storage;
      });

      final flow = AsyncFlow()
        ..start(addNode1)
        ..next(addNode2);

      await flow.run(sharedStorage);
      expect(sharedStorage['result'], 10);
    });
  });
}