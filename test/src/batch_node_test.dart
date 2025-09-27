import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of BatchNode to test its functionalities.
class MockBatchNode extends BatchNode<int, int> {
  bool execCalled = false;
  List<int>? receivedItems;

  @override
  Future<List<int>> exec(List<int> items) async {
    execCalled = true;
    receivedItems = items;
    return items.map((item) => item * 2).toList();
  }
}

void main() {
  group('BatchNode', () {
    late MockBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockBatchNode();
      sharedStorage = {};
    });

    test('run should process a batch of items', () async {
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