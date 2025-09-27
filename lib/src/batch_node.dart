import 'package:pocketflow/src/node.dart';

/// An abstract class for processing a batch of items of type `I` and returning
/// a batch of items of type `O`.
abstract class BatchNode<I, O> extends Node {
  /// The main execution logic for processing a batch of items.
  ///
  /// This method is intended to be implemented by subclasses to define the
  /// specific processing logic for the batch.
  @override
  Future<List<O>> exec(covariant List<I> items);

  @override
  Future<List<I>> prep(Map<String, dynamic> shared) async {
    final items = params['items'];

    if (items == null) {
      throw ArgumentError('The "items" parameter must be provided.');
    }

    if (items is List<I>) {
      return items;
    }

    if (items is List) {
      if (items.every((item) => item is I)) {
        return items.cast<I>();
      } else {
        throw ArgumentError(
          'The "items" parameter must be a List where all elements are of '
          'type $I.',
        );
      }
    }

    throw ArgumentError(
      'The "items" parameter must be a List, but got ${items.runtimeType}.',
    );
  }

  @override
  BatchNode<I, O> clone();
}
