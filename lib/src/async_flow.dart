import 'package:pocketflow/src/async_node.dart';
import 'package:pocketflow/src/flow.dart';

/// A class for orchestrating flows with `async` nodes.
///
/// This class is a specialized [Flow] that is intended to be used with
/// [AsyncNode]s. It provides a convenient way to create and manage asynchronous
/// workflows.
class AsyncFlow extends Flow {
  @override
  /// Creates a deep copy of this [AsyncFlow].
  AsyncFlow clone() {
    return super.copy(AsyncFlow.new);
  }
}
