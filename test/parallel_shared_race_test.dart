import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class ConcurrencyNode extends Node {
  ConcurrencyNode(this.id);
  final int id;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared;
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    // Simulate concurrent access to shared state
    final shared = prepResult as Map<String, dynamic>;
    final currentCounter = shared['counter'] as int;

    // Simulate some async work that could cause race conditions
    await Future<void>.delayed(const Duration(milliseconds: 1));

    // Increment counter (potential race condition)
    shared['counter'] = currentCounter + 1;

    return 'processed';
  }

  @override
  BaseNode createInstance() => ConcurrencyNode(id);
}

void main() {
  test(
    'AsyncParallelBatchFlow with copySharedForParallel avoids race',
    () async {
      final shared = <String, dynamic>{'counter': 0};
      final items = List.generate(10, (i) => {'id': i});
      final nodes = [ConcurrencyNode(0)];
      final flowCopy = AsyncParallelBatchFlow<dynamic, dynamic>(nodes);
      shared['input'] = items;
      await flowCopy.run(shared);
      // when copied per-task, shared.counter remains unchanged (or is only
      // used for each copy). The global shared counter should not be
      // incremented by per-task copies
      expect(shared['counter'], equals(0));

      final flowNoCopy = AsyncParallelBatchFlow<dynamic, dynamic>(
        nodes,
        copySharedForParallel: false,
      );
      // If not copying, concurrent increments may race but the shared state
      // should be modified (counter > 0)
      shared['counter'] = 0;
      shared['input'] = items;
      await flowNoCopy.run(shared);
      // With race conditions, we can't predict the exact final count,
      // but it should be > 0 since the shared state is being modified
      expect(shared['counter'], greaterThan(0));
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
