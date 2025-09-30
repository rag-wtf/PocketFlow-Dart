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
    final currentCounter = shared['counter'] as int? ?? 0;

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
    'ParallelNodeBatchFlow processes items in parallel',
    () async {
      final shared = <String, dynamic>{'counter': 0};
      final items = List.generate(10, (i) => {'id': i});
      final nodes = [ConcurrencyNode(0)];
      final flow = ParallelNodeBatchFlow<dynamic, dynamic>(nodes);
      shared['input'] = items;
      await flow.run(shared);
      // ParallelNodeBatchFlow creates isolated shared state for each item,
      // so the global shared counter should not be incremented
      expect(shared['counter'], equals(0));
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
