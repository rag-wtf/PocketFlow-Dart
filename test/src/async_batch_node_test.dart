import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncBatchNode', () {
    test(
      'should process a batch of items with the provided function',
      () async {
        // Define an async function to process the batch of items
        Future<List<String>> processItems(List<int> items) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return items.map((item) => 'Processed: $item').toList();
        }

        // Create an instance of AsyncBatchNode with the processing function
        final node = AsyncBatchNode<int, String>(processItems);

        // Set the input items for the node
        final inputItems = [1, 2, 3];
        node.params['items'] = inputItems;

        final shared = <String, dynamic>{};
        // Execute the node
        final result = await node.run(shared);

        // Verify the result
        expect(
          result,
          equals(['Processed: 1', 'Processed: 2', 'Processed: 3']),
        );
        // Verify that the shared map is updated
        expect(shared['items'], result);
      },
    );

    test(
      'should retrieve items from shared storage if not in params',
      () async {
        Future<List<String>> processItems(List<int> items) async {
          return items.map((item) => 'Processed: $item').toList();
        }

        final node = AsyncBatchNode<int, String>(processItems);
        final shared = <String, dynamic>{
          'items': [10, 20],
        };
        final result = await node.run(shared);
        expect(result, equals(['Processed: 10', 'Processed: 20']));
        expect(shared['items'], result);
      },
    );

    test('should throw an error if items are not provided', () async {
      // Create an instance of AsyncBatchNode without providing items
      final node = AsyncBatchNode<int, String>((items) async => []);

      // Expect the run method to throw an ArgumentError
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

    group('prep', () {
      test('should throw an error if "items" is not a List', () async {
        final node = AsyncBatchNode<int, int>((item) async => item)
          ..params['items'] = 'not a list';
        expect(
          () => node.prep({}),
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
          final node = AsyncBatchNode<int, int>((item) async => item)
            ..params['items'] = <dynamic>[1, 'two', 3];
          expect(
            () => node.prep({}),
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
        final node = AsyncBatchNode<int, int>((item) async => item);
        node.params['items'] = <dynamic>[1, 2, 3];
        final result = await node.prep({});
        expect(result, isA<List<int>>());
        expect(result, [1, 2, 3]);
      });
    });

    test('clone should create a new instance with the same function', () async {
      // Define an async function
      Future<List<int>> process(List<int> items) async =>
          items.map((i) => i * 2).toList();

      // Create and clone the node
      final original = AsyncBatchNode<int, int>(process)
        ..name = 'original'
        ..params['value'] = 123
        ..params['items'] = [1, 2, 3];
      final clone = original.clone();

      // Check properties
      expect(clone.name, 'original');
      expect(clone.params['value'], 123);

      // Ensure it's a different instance
      expect(identical(original, clone), isFalse);
      // Ensure params is a copy
      expect(identical(original.params, clone.params), isFalse);

      // Change original params, cloned should not be affected
      original.params['value'] = 456;
      expect(clone.params['value'], 123);

      // Execute the clone and verify its behavior
      final result = await clone.run({});
      expect(result, equals([2, 4, 6]));
    });
  });
}
