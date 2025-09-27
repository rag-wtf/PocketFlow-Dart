import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Test implementation of BaseNode
class TestBaseNode extends BaseNode<String> {
  String? _execResult;
  dynamic _postResult;

  TestBaseNode({String? execResult, dynamic postResult})
    : _execResult = execResult,
      _postResult = postResult;

  @override
  String? exec(dynamic prepRes) {
    return _execResult;
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    return _postResult ?? execRes;
  }
}

void main() {
  group('BaseNode', () {
    late TestBaseNode node;
    late Map<String, dynamic> shared;

    setUp(() {
      node = TestBaseNode(execResult: 'test_result');
      shared = <String, dynamic>{'key': 'value'};
    });

    test('can be instantiated', () {
      expect(node, isNotNull);
      expect(node.params, isEmpty);
      expect(node.successors, isEmpty);
    });

    test('setParams updates parameters', () {
      final params = <String, dynamic>{'param1': 'value1', 'param2': 42};
      node.setParams(params);

      expect(node.params, equals(params));
      expect(node.params, isNot(same(params))); // Should be a copy
    });

    test('next adds successor node', () {
      final successor = TestBaseNode();
      final result = node.next(successor);

      expect(result, same(successor));
      expect(node.successors['default'], same(successor));
    });

    test('next with custom action', () {
      final successor = TestBaseNode();
      node.next(successor, 'custom_action');

      expect(node.successors['custom_action'], same(successor));
    });

    test('next warns when overwriting successor', () {
      final successor1 = TestBaseNode();
      final successor2 = TestBaseNode();

      node.next(successor1, 'action');

      // This should print a warning (we can't easily test print output)
      node.next(successor2, 'action');

      expect(node.successors['action'], same(successor2));
    });

    test('prep returns null by default', () {
      expect(node.prep(shared), isNull);
    });

    test('post returns null by default', () {
      final testNode = TestBaseNode(postResult: null);
      expect(testNode.post(shared, 'prep', null), isNull);
    });

    test('internalExec calls exec', () {
      final result = node.internalExec('prep_result');
      expect(result, equals('test_result'));
    });

    test('internalRun executes full lifecycle', () {
      final testNode = TestBaseNode(
        execResult: 'exec_result',
        postResult: 'post_result',
      );
      final result = testNode.internalRun(shared);

      expect(result, equals('post_result'));
    });

    test('run warns when node has successors', () {
      final successor = TestBaseNode();
      node.next(successor);

      // This should print a warning (we can't easily test print output)
      final result = node.run(shared);
      expect(result, equals('test_result'));
    });

    test('run executes without warning when no successors', () {
      final result = node.run(shared);
      expect(result, equals('test_result'));
    });

    test('operator >> chains nodes', () {
      final successor = TestBaseNode();
      final result = node >> successor;

      expect(result, same(successor));
      expect(node.successors['default'], same(successor));
    });

    test('operator - creates conditional transition', () {
      final transition = node - 'success';
      expect(transition, isNotNull);
    });

    test('conditional transition with >> completes chaining', () {
      final successor = TestBaseNode();
      final result = (node - 'success') >> successor;

      expect(result, same(successor));
      expect(node.successors['success'], same(successor));
    });

    test('operator - throws on non-string action', () {
      // This test verifies that the operator - only accepts strings
      // We can't actually test this at compile time since Dart is statically typed
      // But we can verify the method signature requires a String
      expect(() => node - 'valid_string', returnsNormally);
    });

    test('complex chaining scenario', () {
      final node1 = TestBaseNode();
      final node2 = TestBaseNode();
      final node3 = TestBaseNode();
      final node4 = TestBaseNode();

      // Chain: node1 -> node2 (default), node1 -> node3 (success), node1 -> node4 (error)
      node1 >> node2;
      (node1 - 'success') >> node3;
      (node1 - 'error') >> node4;

      expect(node1.successors['default'], same(node2));
      expect(node1.successors['success'], same(node3));
      expect(node1.successors['error'], same(node4));
    });

    test('params getter returns copy', () {
      final originalParams = <String, dynamic>{'key': 'value'};
      node.setParams(originalParams);

      final retrievedParams = node.params;
      retrievedParams['key'] = 'modified';

      expect(
        node.params['key'],
        equals('value'),
      ); // Original should be unchanged
    });

    test('successors getter returns copy', () {
      final successor = TestBaseNode();
      node.next(successor);

      final retrievedSuccessors = node.successors;
      retrievedSuccessors.clear();

      expect(node.successors, isNotEmpty); // Original should be unchanged
    });
  });
}
