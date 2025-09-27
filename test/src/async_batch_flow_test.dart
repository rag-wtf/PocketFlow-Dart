import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Mock nodes for testing AsyncBatchFlow
class MockAsyncBatchNode1 extends AsyncBatchNode<int, int> {
  @override
  Future<List<int>> exec(List<int> items) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return items.map((i) => i * 2).toList();
  }
}

class MockAsyncBatchNode2 extends AsyncBatchNode<int, int> {
  @override
  Future<List<int>> exec(List<int> items) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return items.map((i) => i + 1).toList();
  }
}

void main() {
  group('AsyncBatchFlow', () {
    late AsyncBatchFlow<int, int> flow;
    late MockAsyncBatchNode1 node1;
    late MockAsyncBatchNode2 node2;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node1 = MockAsyncBatchNode1();
      node2 = MockAsyncBatchNode2();
      flow = AsyncBatchFlow<int, int>([node1, node2]);
      sharedStorage = {};
    });

    test('run processes items through all nodes in the flow asynchronously', () async {
      final initialItems = [1, 2, 3];
      flow.params['items'] = initialItems;

      final result = await flow.run(sharedStorage);

      // Node1 multiplies by 2: [2, 4, 6]
      // Node2 adds 1: [3, 5, 7]
      expect(result, equals([3, 5, 7]));
    });
  });
}