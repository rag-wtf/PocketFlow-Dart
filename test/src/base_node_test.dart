import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of BaseNode to test its functionalities.
class MockNode extends BaseNode {
  bool prepCalled = false;
  bool execCalled = false;
  bool postCalled = false;
  dynamic prepResult = 'prep_result';
  dynamic execResult = 'exec_result';
  dynamic postResult;
  dynamic receivedPrepResult;
  dynamic receivedExecResult;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    prepCalled = true;
    return prepResult;
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    execCalled = true;
    receivedPrepResult = prepResult; // To test the new data flow
    return execResult;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    postCalled = true;
    receivedPrepResult = prepResult;
    receivedExecResult = execResult;
    return postResult;
  }
}

void main() {
  group('BaseNode', () {
    late MockNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockNode();
      sharedStorage = {};
    });

    test('run should execute prep, exec, and post methods in order', () async {
      await node.run(sharedStorage);
      expect(node.prepCalled, isTrue, reason: 'prep should be called');
      expect(node.execCalled, isTrue, reason: 'exec should be called');
      expect(node.postCalled, isTrue, reason: 'post should be called');
    });

    test('run should pass prep and exec results to post', () async {
      await node.run(sharedStorage);
      expect(
        node.receivedPrepResult,
        equals(node.prepResult),
        reason: 'post should receive the result from prep',
      );
      expect(
        node.receivedExecResult,
        equals(node.execResult),
        reason: 'post should receive the result from exec',
      );
    });

    test('run should return the result of the post method', () async {
      node.postResult = 'test_result';
      final result = await node.run(sharedStorage);
      expect(
        result,
        equals('test_result'),
        reason: 'run should return the result from post',
      );
    });
  });
}
