import 'package:pocketflow/src/async_node.dart';
import 'package:pocketflow/src/base_node.dart';

/// A function type for an asynchronous batch item execution block.
typedef AsyncBatchItemExecFunction<I, O> = Future<O> Function(I item);

/// A class for defining nodes that process a batch of items asynchronously
/// in sequential order.
///
/// This class matches Python's `AsyncBatchNode` behavior:
/// - `prepAsync()` returns a list of items to process
/// - `execAsyncItem(item)` processes a single item (override this in
///   subclasses)
/// - The base class handles sequential execution (processes items one by one)
/// - `postAsync()` receives the list of results
///
/// The key difference from `AsyncParallelBatchNode` is that items are
/// processed **sequentially** (one after another) rather than in parallel.
///
/// Example:
/// ```dart
/// class SequentialProcessor extends AsyncBatchNode<int, int> {
///   @override
///   Future<List<int>> prepAsync(Map<String, dynamic> shared) async {
///     return shared['numbers'] as List<int>;
///   }
///
///   @override
///   Future<int> execAsyncItem(int item) async {
///     await Future.delayed(Duration(milliseconds: 100));
///     return item * 2;
///   }
///
///   @override
///   Future<String> postAsync(
///     Map<String, dynamic> shared,
///     dynamic prepResult,
///     dynamic execResult,
///   ) async {
///     shared['results'] = execResult;
///     return 'processed';
///   }
/// }
/// ```
class AsyncBatchNode<I, O> extends AsyncNode {
  /// Creates a new `AsyncBatchNode`.
  ///
  /// Can be created with an optional [execFunction] for simple cases,
  /// or subclassed to override `prepAsync`, `execAsyncItem`, and `postAsync`.
  AsyncBatchNode([AsyncBatchItemExecFunction<I, O>? execFunction])
    : _execFunction = execFunction;

  /// The asynchronous function to be executed for each item in the batch.
  /// This is used when the node is created with a function instead of
  /// subclassing.
  final AsyncBatchItemExecFunction<I, O>? _execFunction;

  @override
  /// Prepares the batch of items for processing.
  ///
  /// This method can be overridden in subclasses to provide custom preparation
  /// logic. The default implementation retrieves items from params['items']
  /// or shared['items'] (params takes precedence).
  ///
  /// Returns a list of items to be processed sequentially.
  Future<List<I>> prepAsync(Map<String, dynamic> shared) async {
    // Check params first, then shared (for flow compatibility)
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

  /// Processes a single item asynchronously.
  ///
  /// This method should be overridden in subclasses to define the processing
  /// logic for each individual item. The base class will call this method
  /// for each item sequentially.
  ///
  /// If a function was provided to the constructor, it will be used instead.
  ///
  /// Note: This method has a different signature than the parent's execAsync
  /// because it processes individual items, not the entire prep result.
  Future<O> execAsyncItem(I item) async {
    if (_execFunction != null) {
      return _execFunction(item);
    }
    throw UnimplementedError(
      'execAsyncItem must be overridden in subclasses or a function must be '
      'provided to the constructor.',
    );
  }

  @override
  /// Executes the batch processing sequentially.
  ///
  /// This method applies [execAsyncItem] to each item in the [prepResult]
  /// list one by one, waiting for each to complete before starting the next.
  ///
  /// This matches Python's behavior:
  /// ```python
  /// async def _exec(self, items):
  ///     return [await super()._exec(i) for i in items]
  /// ```
  Future<List<O>> execAsync(dynamic prepResult) async {
    final items = prepResult as List<I>;
    final results = <O>[];
    for (final item in items) {
      final result = await execAsyncItem(item);
      results.add(result);
    }
    return results;
  }

  @override
  /// Post-processes the results after sequential execution.
  ///
  /// This method can be overridden in subclasses to handle the results.
  /// The default implementation updates shared['items'] with the results
  /// (for flow compatibility) and returns the exec result.
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Update shared['items'] for flow compatibility
    shared['items'] = execResult;
    return execResult;
  }

  @override
  /// Creates a new instance of AsyncBatchNode.
  BaseNode createInstance() {
    return AsyncBatchNode<I, O>(_execFunction);
  }

  @override
  /// Creates a copy of this [AsyncBatchNode].
  AsyncBatchNode<I, O> clone() {
    return super.clone() as AsyncBatchNode<I, O>;
  }
}
