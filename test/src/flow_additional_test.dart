import 'package:pocketflow/src/flow.dart';
import 'package:test/test.dart';
import 'batch_node_additional_test.dart';

void main() {
  group('Flow uncovered lines', () {
    test('should cover lines 226, 229 by running with empty nodes', () async {
      final flow = Flow(start: DummyBatchNode());
      final result = await flow.run({'items': <dynamic>[]});
      expect(result, isEmpty);
    });
  });
}
