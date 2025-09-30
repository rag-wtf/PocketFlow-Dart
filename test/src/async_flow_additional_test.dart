import 'package:pocketflow/src/async_flow.dart';
import 'package:test/test.dart';
import 'async_node_additional_test.dart';

void main() {
  group('AsyncFlow uncovered lines', () {
    test('should cover line 41 by running with empty nodes', () async {
      final flow = AsyncFlow(start: DummyAsyncNode());
      final result = await flow.run({'items': <dynamic>[]});
      expect(result, isNull);
    });
  });
}
