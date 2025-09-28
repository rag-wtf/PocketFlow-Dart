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

        // Execute the node
        final result = await node.run({});

        // Verify the result
        expect(
          result,
          equals(['Processed: 1', 'Processed: 2', 'Processed: 3']),
        );
      },
    );

    test('should throw an error if items are not provided', () async {
      // Create an instance of AsyncBatchNode without providing items
      final node = AsyncBatchNode<int, String>((items) async => []);

      // Expect the run method to throw an ArgumentError
      expect(
        () => node.run({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('clone should create a new instance with the same function', () async {
      // Define an async function
      Future<List<int>> process(List<int> items) async =>
          items.map((i) => i * 2).toList();

      // Create and clone the node
      final original = AsyncBatchNode<int, int>(process);
      original.params['items'] = [1, 2, 3];
      final clone = original.clone();

      // Ensure the clone is a different instance
      expect(identical(original, clone), isFalse);

      // Execute the clone and verify its behavior
      final result = await clone.run({});
      expect(result, equals([2, 4, 6]));
    });
  });
}
