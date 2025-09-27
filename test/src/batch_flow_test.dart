import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of BatchNode to test its functionalities within a flow.
class MockMultiplierBatchNode extends BatchNode<int, int> {
  final int multiplier;

  MockMultiplierBatchNode({this.multiplier = 2});

  @override
  Future<List<int>> exec(List<int> items) async {
    return items.map((item) => item * multiplier).toList();
  }

  @override
  BatchNode<int, int> clone() {
    final cloned = MockMultiplierBatchNode(multiplier: multiplier);
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

void main() {
  group('BatchFlow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('should run a simple flow with a single batch node', () async {
      final flow = BatchFlow();
      final node = MockMultiplierBatchNode();
      flow.start(node);

      final items = [1, 2, 3];
      flow.params['items'] = items;

      final result = await flow.run(sharedStorage);

      expect(result, equals([2, 4, 6]));
    });

    test('should chain multiple batch nodes and pass items through', () async {
      final flow = BatchFlow();
      final node1 = MockMultiplierBatchNode(multiplier: 2);
      final node2 = MockMultiplierBatchNode(multiplier: 3);

      flow.start(node1).next(node2);

      final items = [1, 2, 3];
      flow.params['items'] = items;

      final result = await flow.run(sharedStorage);

      // After node1: [2, 4, 6]
      // After node2: [6, 12, 18]
      expect(result, equals([6, 12, 18]));
    });

    test('should pass parameters to nodes within the flow', () async {
      final flow = BatchFlow();
      final node = MockMultiplierBatchNode();
      flow.start(node);

      final items = [10, 20];
      flow.params['items'] = items;

      final result = await flow.run(sharedStorage);

      expect(result, equals([20, 40]));
    });
  });
}
