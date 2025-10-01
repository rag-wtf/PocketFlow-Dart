import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A concrete implementation of BatchNode to test its default exec logic.
class ConcreteBatchNode extends BatchNode<int, int> {
  @override
  Future<int?> execItem(int item) async {
    if (item == 0) return null;
    return item * 2;
  }
}

// A class to test BatchNodeMixin
class _BaseNodeForMixin extends Node {
  @override
  Future<dynamic> exec(dynamic item) async {
    if (item is int && item > 0) {
      return item * 10;
    }
    return null;
  }
}

class NodeWithBatchMixin extends _BaseNodeForMixin
    with BatchNodeMixin<int, int> {
  @override
  Future<List<int>> prep(Map<String, dynamic> shared) async {
    final items = params['items'] ?? shared['items'];
    return items as List<int>;
  }
}

// A concrete implementation of InheritanceAsyncBatchNode for testing.
class MyInheritanceAsyncBatchNode
    extends InheritanceAsyncBatchNode<int, String> {
  MyInheritanceAsyncBatchNode({super.maxRetries, super.wait});

  @override
  Future<String?> execItemAsync(int item) async {
    if (item == 0) return null;
    return 'item: $item';
  }
}

void main() {
  group('BatchNode', () {
    group('with default implementations', () {
      test('execItem should return null', () async {
        final node = BatchNode<int, String>();
        final result = await node.execItem(1);
        expect(result, isNull);
      });

      test('exec should return an empty list', () async {
        final node = BatchNode<int, String>();
        final result = await node.exec([1, 2, 3]);
        expect(result, isEmpty);
      });
    });

    group('.prep()', () {
      late BatchNode<int, String> node;

      setUp(() {
        node = BatchNode<int, String>();
      });

      test('should throw ArgumentError if "items" parameter is missing', () {
        expect(
          () => node.prep({}),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError if "items" is not a List', () {
        node.params['items'] = 123;
        expect(
          () => node.prep({}),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'should throw ArgumentError if "items" has incorrect item types',
        () {
          node.params['items'] = ['a', 'b', 'c'];
          expect(
            () => node.prep({}),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test(
        'should throw ArgumentError if a dynamic list has incorrect item types',
        () {
          node.params['items'] = <dynamic>[1, 'a', 3];
          expect(
            () => node.prep({}),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('should handle a List<int> directly', () async {
        final items = [1, 2, 3];
        node.params['items'] = items;
        final result = await node.prep({});
        expect(result, isA<List<int>>());
        expect(result, equals(items));
      });

      test('should handle a List<dynamic> with correct item types', () async {
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.prep({});
        expect(result, isA<List<int>>());
        expect(result, equals([1, 2, 3]));
      });
    });

    test('clone should create a new instance with the same properties', () {
      final node = BatchNode<int, int>()
        ..name = 'TestNode'
        ..params['value'] = 42;

      final clonedNode = node.clone();

      expect(clonedNode, isA<BatchNode<int, int>>());
      expect(clonedNode.name, equals('TestNode'));
      expect(clonedNode.params['value'], equals(42));
      expect(clonedNode, isNot(same(node)));
    });
  });

  group('ConcreteBatchNode', () {
    late ConcreteBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = ConcreteBatchNode();
      sharedStorage = {};
    });

    test('should use default batch implementation', () async {
      node.params['items'] = [1, 2, 3];
      final result = await node.run(sharedStorage);
      expect(result, equals([2, 4, 6]));
    });

    test('should filter out null results from execItem', () async {
      node.params['items'] = [1, 0, 3];
      final result = await node.run(sharedStorage);
      expect(result, equals([2, 6]));
    });

    test('should handle empty list', () async {
      node.params['items'] = const <int>[];
      final result = await node.run(sharedStorage);
      expect(result, equals(const []));
    });
  });

  group('BatchNodeMixin', () {
    late NodeWithBatchMixin node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = NodeWithBatchMixin();
      sharedStorage = {};
    });

    test('should process items using the mixin', () async {
      node.params['items'] = [1, 2, 3];
      final result = await node.run(sharedStorage);
      expect(result, equals([10, 20, 30]));
    });

    test('should handle empty list with mixin', () async {
      node.params['items'] = <int>[];
      final result = await node.run(sharedStorage);
      expect(result, equals([]));
    });

    test('mixin should filter out nulls', () async {
      node.params['items'] = [1, 0, 2, -1];
      final result = await node.run(sharedStorage);
      expect(result, equals([10, 20]));
    });
  });

  group('InheritanceAsyncBatchNode', () {
    late MyInheritanceAsyncBatchNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MyInheritanceAsyncBatchNode();
      sharedStorage = {};
    });

    test('should process a batch of items', () async {
      node.params['items'] = [1, 2, 3];
      final result = await node.run(sharedStorage);
      expect(result, equals(['item: 1', 'item: 2', 'item: 3']));
    });

    test('should handle empty list', () async {
      node.params['items'] = const <int>[];
      final result = await node.run(sharedStorage);
      expect(result, equals(const []));
    });

    test('should filter out null results', () async {
      node.params['items'] = [1, 0, 2];
      final result = await node.run(sharedStorage);
      expect(result, equals(['item: 1', 'item: 2']));
    });

    test('prepAsync should throw an error if "items" is not provided', () {
      expect(
        () => node.run({}),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'The "items" parameter must be provided.',
          ),
        ),
      );
    });

    test('prepAsync should throw an error if "items" is not a List', () {
      node.params['items'] = 'not a list';
      expect(
        () => node.run({}),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'The "items" parameter must be a List, but got String.',
          ),
        ),
      );
    });

    test(
      'prepAsync should throw an error if "items" is a list of the wrong type',
      () {
        node.params['items'] = ['a', 'b'];
        expect(
          () => node.run({}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              '''
The "items" parameter must be a List where all elements are of type int.''',
            ),
          ),
        );
      },
    );

    test(
      'prepAsync should handle a List<dynamic> with correct item types',
      () async {
        node.params['items'] = <dynamic>[1, 2];
        final result = await node.run({});
        expect(result, equals(['item: 1', 'item: 2']));
      },
    );

    test('should retrieve items from shared storage', () async {
      sharedStorage['items'] = [10, 20];
      final result = await node.run(sharedStorage);
      expect(result, equals(['item: 10', 'item: 20']));
    });

    test('clone should create a deep copy', () {
      node.params['x'] = 1;
      final clone = node.clone();
      expect(clone.params['x'], 1);
      expect(clone, isNot(same(node)));
      clone.params['x'] = 2;
      expect(node.params['x'], 1);
    });
  });
}
