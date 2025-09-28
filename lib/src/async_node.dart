import 'package:pocketflow/src/node.dart';

/// A function type for an asynchronous execution block.
typedef AsyncExecFunction = Future<dynamic> Function(dynamic prepResult);

/// A class for defining nodes with `async`/`await` native methods.
///
/// `AsyncNode` is a convenience class that simplifies the creation of nodes
/// that perform an asynchronous operation. Instead of creating a new class
/// that extends [Node] and overriding the `exec` method, you can pass an
/// [AsyncExecFunction] directly to the constructor.
class AsyncNode extends Node {
  /// Creates a new `AsyncNode`.
  ///
  /// - [execFunction]: The asynchronous function to be executed by this node.
  AsyncNode(AsyncExecFunction execFunction) : _execFunction = execFunction;

  /// The asynchronous function to be executed by this node.
  final AsyncExecFunction _execFunction;

  @override
  /// Prepares the data for the `exec` method.
  ///
  /// This implementation simply returns the [shared] map.
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared;
  }

  @override
  /// Executes the asynchronous function.
  ///
  /// This method calls the [_execFunction] that was passed to the constructor.
  Future<dynamic> exec(dynamic prepResult) {
    return _execFunction(prepResult);
  }

  @override
  /// Creates a copy of this [AsyncNode].
  AsyncNode clone() {
    return AsyncNode(_execFunction)
      ..name = name
      ..params = Map.from(params);
  }
}
