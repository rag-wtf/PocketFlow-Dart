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

  @override
  BaseNode clone() {
    final cloned = MockNode();
    cloned.params = Map.from(params);
    return cloned;
  }
}

// A node that uses the default prep, exec, and post implementations.
class DefaultNode extends BaseNode {
  @override
  BaseNode clone() {
    final cloned = DefaultNode();
    cloned.params = Map.from(params);
    return cloned;
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

    test('next() should set a successor', () {
      final nextNode = MockNode();
      node.next(nextNode);
      expect(node.successors['default'], same(nextNode));
    });

    test('next() should set a successor with a custom action', () {
      final nextNode = MockNode();
      node.next(nextNode, action: 'custom');
      expect(node.successors['custom'], same(nextNode));
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

  group('BaseNode default implementations', () {
    late DefaultNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = DefaultNode();
      sharedStorage = {};
    });

    test('default prep should do nothing and return null', () async {
      final result = await node.prep(sharedStorage);
      expect(result, isNull);
    });

    test('default exec should do nothing and return null', () async {
      final result = await node.exec(null);
      expect(result, isNull);
    });

    test('default post should do nothing and return null', () async {
      final result = await node.post(sharedStorage, null, null);
      expect(result, isNull);
    });

    test(
      'run with default implementations should complete and return null',
      () async {
        final result = await node.run(sharedStorage);
        expect(result, isNull);
      },
    );
  });

  group('BaseNode.clone()', () {
    test('should create a new instance with the same properties', () {
      final original = MockNode();
      original.params['key'] = 'value';

      final cloned = original.clone();

      expect(cloned, isNot(same(original)));
      expect(cloned.params, equals(original.params));
    });
  });
}
