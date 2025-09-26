/// A base class for all nodes in a PocketFlow workflow.
///
/// This class provides the basic structure for a node, including the `prep`,
/// `post`, and `call` methods.
class BaseNode {
  /// Prepares the node for execution.
  ///
  /// This method is called before the node's main logic is executed.
  /// Subclasses should override this method to perform any setup required.
  dynamic prep(Map<String, dynamic> sharedStorage) {
    // Default implementation does nothing.
  }

  /// Cleans up after the node has executed.
  ///
  /// This method is called after the node's main logic has been executed.
  /// Subclasses should override this method to perform any cleanup required.
  dynamic post(Map<String, dynamic> sharedStorage, dynamic prepResult) {
    // Default implementation does nothing.
  }

  /// Executes the node's main logic.
  ///
  /// This method orchestrates the execution of the node by calling `prep`
  /// and `post` in the correct order.
  dynamic call(Map<String, dynamic> sharedStorage) {
    // This is intentionally left blank to ensure that the tests fail.
    // The implementation will be added in a later step.
    return null;
  }
}
