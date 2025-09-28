import 'package:pocketflow/src/flow.dart';

/// A class for orchestrating flows with `async` nodes.
class AsyncFlow extends Flow {
  @override
  AsyncFlow clone() {
    return super.copy(AsyncFlow.new);
  }
}
