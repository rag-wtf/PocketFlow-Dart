import 'flow.dart';

/// A flow that processes batches of parameters.
///
/// Extends [Flow] to handle batch processing by running the flow
/// multiple times with different parameter sets.
class BatchFlow<T> extends Flow<T> {
  /// Create a new BatchFlow
  ///
  /// [startNode] Optional starting node for the flow
  BatchFlow([super.startNode]);

  /// Internal run method for batch processing
  @override
  dynamic internalRun(Map<String, dynamic> shared) {
    final prepRes = prep(shared);

    // prepRes should be a list of parameter maps for batch processing
    final batchParams =
        prepRes as List<Map<String, dynamic>>? ?? <Map<String, dynamic>>[];

    // Process each batch item
    for (final batchParam in batchParams) {
      final mergedParams = <String, dynamic>{
        ...params,
        ...batchParam,
      };
      internalOrchestrate(shared, mergedParams);
    }

    return post(shared, prepRes, null);
  }
}
