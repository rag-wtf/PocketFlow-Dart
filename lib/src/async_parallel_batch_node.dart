import 'dart:async';

import 'package:pocketflow/src/node.dart';

/// A function type for an asynchronous, parallel batch item execution block.
typedef AsyncParallelBatchItemExecFunction<I, O> = Future<O> Function(I item);

/// A class for defining nodes that process a batch of items asynchronously
/// and in parallel.
///
/// `AsyncParallelBatchNode` is a convenience class that simplifies the creation
/// of nodes that perform an asynchronous, parallel batch operation. You provide
/// a function that processes a single item, and the node will apply this
/// function to all items in the input batch concurrently using `Future.wait`.
class AsyncParallelBatchNode<I, O> extends Node {
  /// Creates a new `AsyncParallelBatchNode`.
  ///
  /// - [_execFunction]: The asynchronous function to be executed for each
  ///   item in the batch.
  AsyncParallelBatchNode(this._execFunction);

  final AsyncParallelBatchItemExecFunction<I, O> _execFunction;

  /// A convenience method to execute the node directly with a list of items.
  ///
  /// This is primarily for ease of use and testing. It sets the [items] in
  /// the node's parameters and calls the `run` method.
  Future<List<O>> call(List<I> items) async {
    params['items'] = items;
    final result = await run(params);
    // The result from `run` is dynamic, so we cast it to the expected type.
    if (result is List) {
      return result.cast<O>();
    }
    // This path should ideally not be reached if `exec` is correct.
    return [];
  }

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
  Future<List<O>> exec(covariant List<I> prepResult) {
    final futures = prepResult.map(_execFunction).toList();
    return Future.wait(futures);
  }

  @override
  AsyncParallelBatchNode<I, O> clone() {
    return AsyncParallelBatchNode<I, O>(_execFunction)
      ..name = name
      ..params = Map.from(params);
  }
}
