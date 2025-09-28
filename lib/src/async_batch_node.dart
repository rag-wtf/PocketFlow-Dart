import 'package:pocketflow/src/node.dart';

/// A function type for an asynchronous batch execution block.
typedef AsyncBatchExecFunction<I, O> = Future<List<O>> Function(List<I> items);

/// A class for defining nodes that process a batch of items asynchronously.
///
/// `AsyncBatchNode` is a convenience class that simplifies the creation of
/// nodes that perform an asynchronous batch operation. Instead of creating a
/// new class that extends [Node] and implementing the batch logic, you can
//  pass an [AsyncBatchExecFunction] directly to the constructor.
class AsyncBatchNode<I, O> extends Node {
  /// Creates a new `AsyncBatchNode`.
  ///
  /// - [_execFunction]: The asynchronous function to be executed by this node.
  AsyncBatchNode(this._execFunction);

  final AsyncBatchExecFunction<I, O> _execFunction;

  @override
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
  Future<List<O>> exec(covariant List<I> prepResult) {
    return _execFunction(prepResult);
  }

  @override
  AsyncBatchNode<I, O> clone() {
    return AsyncBatchNode<I, O>(_execFunction)
      ..name = name
      ..params = Map.from(params);
  }

  @override
  Future<dynamic> run(Map<String, dynamic> shared) async {
    final result = await super.run(shared);
    shared['items'] = result;
    return result;
  }
}
