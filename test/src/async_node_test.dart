import 'package:pocketflow/src/async_node.dart';
import 'package:pocketflow/src/node.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncNode', () {
    test('should inherit from Node', () {
      final asyncNode = SimpleAsyncNode((_) async => null);
      expect(asyncNode, isA<Node>());
    });

    test(
      'should execute the async function provided in the constructor',
      () async {
        const expectedResult = 'test_result';
        final asyncNode = SimpleAsyncNode((_) async => expectedResult);
        final result = await asyncNode.execAsync(null);
        expect(result, equals(expectedResult));
      },
    );

    test(
      'should pass the prepResult to the async function in the constructor',
      () async {
        const prepData = {'key': 'value'};
        final asyncNode = SimpleAsyncNode((dynamic prepResult) async {
          expect(prepResult, equals(prepData));
          return 'done';
        });
        await asyncNode.execAsync(prepData);
      },
    );

    test(
      'clone() should create a new instance with the same exec function',
      () async {
        const expectedResult = 'cloned_result';
        final originalNode = SimpleAsyncNode((_) async => expectedResult)
          ..name = 'Original';

        final clonedNode = originalNode.clone();

        expect(clonedNode, isA<SimpleAsyncNode>());
        expect(clonedNode.name, equals('Original'));
        expect(clonedNode, isNot(same(originalNode)));

        final result = await clonedNode.execAsync(null);
        expect(result, equals(expectedResult));
      },
    );
  });
}
