import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of AsyncBatchNode to test its functionalities.
class MockAsyncBatchNode extends AsyncBatchNode<int, int> {
  bool execCalled = false;
  List<int>? receivedItems;

  @override
  Future<List<int>> exec(List<int> items) async {
    execCalled = true;
    receivedItems = items;
    // Simulate an async operation
    await Future.delayed(const Duration(milliseconds: 10));
    return items.map((item) => item * 2).toList();
  }
}

void main() {
  group('AsyncBatchNode', () {
    late MockAsyncBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockAsyncBatchNode();
      sharedStorage = {};
    });

    test('run should process a batch of items asynchronously', () async {
      final items = [1, 2, 3];
      node.params['items'] = items; // Pass items to the node

      final result = await node.run(sharedStorage);

      expect(node.execCalled, isTrue, reason: 'exec should be called');
      expect(
        node.receivedItems,
        equals(items),
        reason: 'exec should receive the list of items',
      );
      expect(
        result,
        equals([2, 4, 6]),
        reason: 'run should return the processed items',
      );
    });
  });
}