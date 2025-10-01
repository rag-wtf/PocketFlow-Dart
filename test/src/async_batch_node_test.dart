import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class MyAsyncBatchNode extends AsyncBatchNode<int, int> {
  MyAsyncBatchNode(super.execFunction);

  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    return 'overridden';
  }
}

void main() {
  group('AsyncBatchNode', () {
    test('should process a batch of items with the provided function', () async {
      final node = AsyncBatchNode<int, int>((item) async => item * 2)
        ..params['items'] = [1, 2, 3];
      final result = await node.run({});
      expect(result, equals([2, 4, 6]));
    });

    test('should retrieve items from shared storage if not in params',
        () async {
      final node = AsyncBatchNode<int, int>((item) async => item * 2);
      final shared = {'items': [4, 5, 6]};
      final result = await node.run(shared);
      expect(result, equals([8, 10, 12]));
    });

    test('should throw an error if items are not provided', () {
      final node = AsyncBatchNode<int, int>((item) async => item * 2);
      expect(
          () => node.run({}),
          throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
              'The "items" parameter must be provided.')));
    });

    test('should allow overriding postAsync', () async {
      final node = MyAsyncBatchNode((item) async => item * 2)
        ..params['items'] = [1, 2, 3];
      final result = await node.run({});
      expect(result, 'overridden');
    });

    group('prepAsync', () {
      late AsyncBatchNode<int, int> node;

      setUp(() {
        node = AsyncBatchNode<int, int>((item) async => item * 2);
      });

      test('should throw an error if "items" is not a List', () {
        node.params['items'] = 'not a list';
        expect(
            () => node.prepAsync({}),
            throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
                'The "items" parameter must be a List, but got String.')));
      });

      test(
          'should throw an error if "items" is a list of the wrong type',
          () {
        node.params['items'] = <String>['a', 'b'];
        expect(
            () => node.prepAsync({}),
            throwsA(isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'The "items" parameter must be a List where all elements are of type int.')));
      });

      test('should handle a List<dynamic> with correct item types', () async {
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.prepAsync({});
        expect(result, isA<List<int>>());
        expect(result, equals([1, 2, 3]));
      });
    });

    test('clone should create a new instance with the same function', () async {
      Future<int> execFunction(int item) async => item * 2;
      final originalNode = AsyncBatchNode<int, int>(execFunction)
        ..name = 'original'
        ..params['value'] = 123
        ..params['items'] = [10];

      final clonedNode = originalNode.clone();

      expect(clonedNode.name, 'original');
      expect(clonedNode.params['value'], 123);

      // Ensure it's a different instance
      expect(clonedNode, isNot(same(originalNode)));
      // Ensure params is a copy
      expect(clonedNode.params, isNot(same(originalNode.params)));

      // Change original params, cloned should not be affected
      originalNode.params['value'] = 456;
      expect(clonedNode.params['value'], 123);

      // Check if the exec function is the same
      final result = await clonedNode.run({});
      expect(result, [20]);
    });

    test('should throw UnimplementedError if execAsyncItem is not implemented',
        () {
      final node = AsyncBatchNode<int, int>();
      node.params['items'] = [1, 2, 3];
      expect(
        () => node.run(<String, dynamic>{}),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}