import 'package:pocketflow/src/async_node.dart';
import 'package:pocketflow/src/base_node.dart';
import 'package:pocketflow/src/node.dart';

/// A concrete class for processing a batch of items of type `I` and returning
/// a batch of items of type `O`.
///
/// This node is useful for performing the same operation on a list of items.
/// The `prep` method extracts the list of items from the node's parameters,
/// and the `exec` method processes the list by calling the parent Node's
/// `exec` method for each item individually.
///
/// This matches Python's BatchNode design where it provides a default
/// implementation that processes items one by one.
class BatchNode<I, O> extends Node {
  /// The main execution logic for processing a batch of items.
  ///
  /// This default implementation calls the `execItem` method for each item
  /// in the [items] list. Subclasses can override `execItem` to provide
  /// custom item processing logic, or override this method for custom
  /// batch processing logic.
  ///
  /// The [items] parameter is a list of items to be processed, and the method
  /// returns a list of processed items.
  @override
  Future<List<O>> exec(covariant List<I> items) async {
    if (items.isEmpty) return <O>[];

    final results = <O>[];
    for (final item in items) {
      final result = await execItem(item);
      if (result != null) {
        results.add(result as O);
      }
    }
    return results;
  }

  /// Processes a single item.
  ///
  /// This method is called for each item in the batch. The default
  /// implementation returns null. Subclasses should override this method
  /// to provide custom item processing logic.
  ///
  /// This matches Python's pattern where BatchNode calls the parent's
  /// _exec method for each individual item.
  Future<O?> execItem(I item) async {
    return null;
  }

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
  /// Creates a new instance of BatchNode with the same type parameters.
  BaseNode createInstance() {
    return BatchNode<I, O>();
  }

  @override
  /// Creates a copy of this [BatchNode].
  ///
  /// This implementation uses the factory pattern to create a new instance
  /// with the same properties.
  BatchNode<I, O> clone() {
    return super.clone() as BatchNode<I, O>;
  }
}

/// A mixin that provides batch processing capabilities for synchronous nodes.
///
/// This mixin can be applied to Node subclasses to add batch processing
/// functionality. It processes items one by one using the parent's exec method.
mixin BatchNodeMixin<I, O> on Node {
  @override
  Future<List<O>> exec(covariant List<I> prepResult) async {
    if (prepResult.isEmpty) return <O>[];

    final results = <O>[];
    for (final item in prepResult) {
      final result = await super.exec(item);
      if (result != null) {
        results.add(result as O);
      }
    }
    return results;
  }
}

/// An AsyncNode that processes batches of items asynchronously using
/// inheritance.
///
/// This class extends AsyncNode to provide batch processing capabilities.
/// It processes items one by one using the async lifecycle methods.
///
/// This matches Python's AsyncBatchNode design and represents the new
/// inheritance-based pattern that should eventually replace the function-based
/// AsyncBatchNode.
class InheritanceAsyncBatchNode<I, O> extends AsyncNode {
  /// Creates a new InheritanceAsyncBatchNode.
  InheritanceAsyncBatchNode({super.maxRetries = 1, super.wait = Duration.zero});

  @override
  /// Prepares the batch of items for processing.
  ///
  /// This method retrieves the list of items from the node's parameters or
  /// shared storage. It expects a parameter named "items" which should be
  /// a `List<I>`.
  ///
  /// Throws an [ArgumentError] if the "items" parameter is not provided or is
  /// of the wrong type.
  Future<List<I>> prepAsync(Map<String, dynamic> shared) async {
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
  /// Processes the batch of items.
  ///
  /// This method processes each item in the batch by calling `execItemAsync`
  /// for each item. The default implementation of `execItemAsync` returns null.
  /// Subclasses should override `execItemAsync` to provide custom processing.
  Future<List<O>> execAsync(dynamic prepResult) async {
    final items = prepResult as List<I>;
    if (items.isEmpty) return <O>[];

    final results = <O>[];
    for (final item in items) {
      final result = await execItemAsync(item);
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  /// Processes a single item asynchronously.
  ///
  /// This method is called for each item in the batch. The default
  /// implementation returns null. Subclasses should override this method
  /// to provide custom async item processing logic.
  ///
  /// This matches Python's pattern where AsyncBatchNode calls the parent's
  /// _exec method for each individual item.
  Future<O?> execItemAsync(I item) async {
    return null;
  }

  @override
  /// Creates a new instance of InheritanceAsyncBatchNode with the same
  /// parameters.
  BaseNode createInstance() {
    return InheritanceAsyncBatchNode<I, O>(
      maxRetries: maxRetries,
      wait: wait,
    );
  }

  @override
  InheritanceAsyncBatchNode<I, O> clone() {
    return super.clone() as InheritanceAsyncBatchNode<I, O>;
  }
}
