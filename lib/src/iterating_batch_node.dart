import 'package:pocketflow/src/node.dart';

/// An abstract class for processing a batch of items of type `I` by iterating
/// over them and returning a batch of items of type `O`.
///
/// This node is useful for performing the same asynchronous operation on each
/// item in a list. The `prep` method extracts the list of items from the
/// node's parameters, and the `run` method iterates over the list, calling
/// `exec` for each item.
abstract class IteratingBatchNode<I, O> extends Node {
  /// The main execution logic for processing a single item.
  ///
  /// This method is intended to be implemented by subclasses to define the
  /// specific processing logic for a single item. The [item] parameter is a
  /// single item to be processed, and the method should return a processed
  /// item.
  @override
  Future<O> exec(covariant I item);

  @override
  /// Prepares the batch of items for processing.
  ///
  /// This method retrieves the list of items from the node's parameters. It
  /// expects a parameter named "items" which should be a `List<I>`.
  ///
  /// Throws an [ArgumentError] if the "items" parameter is not provided or is
  /// of the wrong type.
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

  /// Runs the batch processing by iterating over the items.
  ///
  /// This method first calls `prep` to get the list of items and then iterates
  /// over the list, calling `exec` for each item. The results are collected
  /// into a list and returned.
  @override
  Future<List<O>> run(Map<String, dynamic> shared) async {
    final items = await prep(shared);
    final results = <O>[];
    for (final item in items) {
      results.add(await exec(item));
    }
    return results;
  }

  @override
  /// Creates a copy of this [IteratingBatchNode].
  ///
  /// Subclasses must implement this to support cloning.
  IteratingBatchNode<I, O> clone();
}
