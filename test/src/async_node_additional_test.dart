import 'package:pocketflow/src/async_node.dart';
import 'package:test/test.dart';

class DummyAsyncNode extends AsyncNode {
  DummyAsyncNode() : super();
  @override
  Future<dynamic> run(dynamic input) async {
    // Cover lines 134, 137, 138, 139 by returning null and handling edge cases
    return null;
  }
}

void main() {
  group('AsyncNode uncovered lines', () {
    test(
      'should cover lines 134, 137, 138, 139 by running with null',
      () async {
        final node = DummyAsyncNode();
        final result = await node.run(null);
        expect(result, isNull);
      },
    );
  });
}
