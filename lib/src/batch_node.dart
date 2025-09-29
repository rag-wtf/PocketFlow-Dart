import 'package:pocketflow/src/node.dart';

/// An abstract class for processing a batch of items of type `I` and returning
/// a batch of items of type `O`.
///
/// This node is useful for performing the same operation on a list of items.
/// The `prep` method extracts the list of items from the node's parameters,
/// and the `exec` method processes the list.
abstract class BatchNode<I, O> extends Node {
  /// The main execution logic for processing a batch of items.
  ///
  /// This method is intended to be implemented by subclasses to define the
  /// specific processing logic for the batch. The [items] parameter is a list
  /// of items to be processed, and the method should return a list of processed
  /// items.
  @override
  Future<List<O>> exec(covariant List<I> items);

  @override
  /// Prepares the batch of items for processing.
  ///
  /// This method retrieves the list of items from the node's parameters. It
  /// expects a parameter named "items" which should be a `List<I>`.
  ///
  /// Throws an [ArgumentError] if the "items" parameter is not provided or is
  /// of the wrong type.
  Future<List<I>> prep(Map<String, dynamic> shared) async {
    final items = params['items'] ?? shared['items'];

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
  /// Creates a copy of this [BatchNode].
  ///
  /// Subclasses must implement this to support cloning.
  BatchNode<I, O> clone();
}
