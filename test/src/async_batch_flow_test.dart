import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncBatchFlow', () {
    late AsyncBatchFlow<int, int> flow;
    late AsyncBatchNode<int, int> node1;
    late AsyncBatchNode<int, int> node2;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      // Define the first node's processing logic
      node1 = AsyncBatchNode<int, int>((items) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return items.map((i) => i * 2).toList();
      });

      // Define the second node's processing logic
      node2 = AsyncBatchNode<int, int>((items) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return items.map((i) => i + 1).toList();
      });

      flow = AsyncBatchFlow<int, int>([node1, node2]);
      sharedStorage = {};
    });

    test(
      'run processes items through all nodes in the flow asynchronously',
      () async {
        final initialItems = [1, 2, 3];
        flow.params['items'] = initialItems;

        final result = await flow.run(sharedStorage);

        // Node1 multiplies by 2: [2, 4, 6]
        // Node2 adds 1: [3, 5, 7]
        expect(result, equals([3, 5, 7]));
      },
    );
  });
}
