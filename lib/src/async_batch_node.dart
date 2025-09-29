import 'package:pocketflow/src/base_node.dart';
import 'package:pocketflow/src/node.dart';

/// A function type for an asynchronous batch execution block.
typedef AsyncBatchExecFunction<I, O> = Future<List<O>> Function(List<I> items);

/// A class for defining nodes that process a batch of items asynchronously.
///
/// `AsyncBatchNode` is a convenience class that simplifies the creation of
/// nodes that perform an asynchronous batch operation. Instead of creating a
/// new class that extends [Node] and implementing the batch logic, you can
/// pass an [AsyncBatchExecFunction] directly to the constructor.
class AsyncBatchNode<I, O> extends Node {
  /// Creates a new `AsyncBatchNode`.
  ///
  /// - [execFunction]: The asynchronous function to be executed by this node.
  AsyncBatchNode(AsyncBatchExecFunction<I, O> execFunction)
    : _execFunction = execFunction;

  /// The asynchronous function to be executed by this node.
  final AsyncBatchExecFunction<I, O> _execFunction;

  @override
  /// Prepares the batch of items for processing.
  ///
  /// This method retrieves the list of items from the `shared` map or the
  /// node's parameters. It expects a parameter named "items" which should be
  /// a `List<I>`.
  ///
  /// Throws an [ArgumentError] if the "items" parameter is not provided or is
  /// of the wrong type.
  Future<List<I>> prep(Map<String, dynamic> shared) async {
    final items = shared['items'] ?? params['items'];

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
  /// Executes the asynchronous batch function.
  ///
  /// This method calls the [_execFunction] that was passed to the constructor.
  Future<List<O>> exec(covariant List<I> prepResult) {
    return _execFunction(prepResult);
  }

  @override
  /// Creates a new instance of AsyncBatchNode with the same function.
  BaseNode createInstance() {
    return AsyncBatchNode<I, O>(_execFunction);
  }

  @override
  /// Creates a copy of this [AsyncBatchNode].
  AsyncBatchNode<I, O> clone() {
    return super.clone() as AsyncBatchNode<I, O>;
  }

  @override
  /// Executes the node's lifecycle and updates the shared state.
  ///
  /// This method calls the parent `run` method and then stores the result
  /// back into the `shared` map under the key "items". This allows subsequent
  /// nodes in the flow to access the processed batch.
  Future<dynamic> run(Map<String, dynamic> shared) async {
    final result = await super.run(shared);
    shared['items'] = result;
    return result;
  }
}
