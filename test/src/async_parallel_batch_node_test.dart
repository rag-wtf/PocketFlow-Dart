import 'package:pocketflow/src/async_parallel_batch_node.dart';
import 'package:test/test.dart';

// A helper class to test the non-list return path.
class _TestNode<I, O> extends AsyncParallelBatchNode<I, O> {
  _TestNode(super.execFunction);

  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Return a non-list to test the defensive code.
    return 'not a list';
  }
}

void main() {
  group('AsyncParallelBatchNode', () {
    test(
      'should process a batch of inputs and return a batch of outputs '
      'in parallel',
      () async {
        final node = AsyncParallelBatchNode<int, int>(
          (value) => Future.delayed(
            const Duration(milliseconds: 100),
            () => value * 2,
          ),
        )..params['items'] = [1, 2, 3];

        final shared = <String, dynamic>{};
        final outputs = await node.run(shared);
        expect(outputs, equals([2, 4, 6]));
      },
    );

    test('should handle an empty batch', () async {
      final node = AsyncParallelBatchNode<int, int>(
        (value) => Future.value(value * 2),
      )..params['items'] = <int>[];

      final shared = <String, dynamic>{};
      final outputs = await node.run(shared);
      expect(outputs, isEmpty);
    });

    test('should propagate errors for failing futures', () async {
      final node = AsyncParallelBatchNode<int, int>(
        (value) => Future.error('An error occurred'),
      )..params['items'] = [1, 2, 3];

      final shared = <String, dynamic>{};
      expect(() => node.run(shared), throwsA(isA<String>()));
    });

    group('prepAsync', () {
      test('should throw an error if "items" is not provided', () async {
        final node = AsyncParallelBatchNode<int, int>((item) async => item);
        // No 'items' in params
        expect(
          () => node.prepAsync({}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'The "items" parameter must be provided.',
            ),
          ),
        );
      });

      test('should throw an error if "items" is not a List', () async {
        final node = AsyncParallelBatchNode<int, int>((item) async => item)
          ..params['items'] = 'not a list';
        expect(
          () => node.prepAsync({}),
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
        'should throw an error if "items" is a list of the wrong type',
        () async {
          final node = AsyncParallelBatchNode<int, int>((item) async => item)
            ..params['items'] = <dynamic>[1, 'two', 3];
          expect(
            () => node.prepAsync({}),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                'The "items" parameter must be a List where all elements are '
                    'of type int.',
              ),
            ),
          );
        },
      );

      test('should handle a List<dynamic> with correct item types', () async {
        final node = AsyncParallelBatchNode<int, int>((item) async => item);
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.prepAsync({});
        expect(result, isA<List<int>>());
        expect(result, [1, 2, 3]);
      });
    });

    test(
      'run should return non-list result from postAsync',
      () async {
        final node = _TestNode<int, int>((item) async => item * 2)
          ..params['items'] = [1, 2, 3];

        final shared = <String, dynamic>{};
        final result = await node.run(shared);
        expect(result, equals('not a list'));
      },
    );

    test('clone should create a new instance with the same function', () async {
      Future<int> execFunction(int item) async => item * 2;
      final originalNode = AsyncParallelBatchNode<int, int>(execFunction)
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
      final shared = <String, dynamic>{};
      final result = await clonedNode.run(shared);
      expect(result, [20]);
    });
  });
}
