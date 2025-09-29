/// Dart-specific extensions for PocketFlow.
///
/// This library contains convenience classes and patterns that are specific
/// to the Dart implementation and are not part of the core Python PocketFlow
/// runtime. These extensions provide additional functionality and patterns
/// that leverage Dart's type system and language features.
///
/// ## Usage
///
/// ```dart
/// import 'package:pocketflow/pocketflow_extensions.dart';
///
/// // Use core classes
/// final node = SimpleAsyncNode((input) async => input * 2);
///
/// // Use extension classes
/// final batchNode = IteratingBatchNode<int, int>();
/// final parallelFlow = ParallelNodeBatchFlow([node1, node2]);
/// final streamingFlow = StreamingBatchFlow([node1, node2]);
/// ```
///
/// ## Extensions Included:
///
/// - **IteratingBatchNode**: A convenience class for processing batches by
///   iterating over individual items with automatic retry logic per item.
///
/// - **ParallelNodeBatchFlow**: A flow that executes multiple nodes in parallel
///   for each item in a batch, useful for independent operations on each item.
///
/// - **StreamingBatchFlow**: A flow that processes batches sequentially
///   through a pipeline of nodes, where each node receives and modifies the
///   entire batch.
///
/// These extensions are designed to complement the core PocketFlow library
/// and provide additional patterns for common use cases in Dart applications.
///
/// For detailed documentation and examples, see [EXTENSIONS.md](EXTENSIONS.md).
library;

// Export the core library for convenience
export 'pocketflow.dart';

// Export Dart-specific extensions
export 'src/iterating_batch_node.dart';
export 'src/parallel_node_batch_flow.dart';
export 'src/streaming_batch_flow.dart';
