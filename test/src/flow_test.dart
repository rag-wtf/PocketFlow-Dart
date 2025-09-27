import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Test implementation of Node for Flow testing
class TestFlowNode extends Node<String> {
  final String _execResult;
  final String? _postResult;
  final List<String> _executionLog;

  TestFlowNode(this._execResult, this._executionLog, {String? postResult})
    : _postResult = postResult;

  @override
  String? exec(dynamic prepRes) {
    _executionLog.add('exec:$_execResult');
    return _execResult;
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    final result = _postResult ?? execRes;
    _executionLog.add('post:$result');
    return result;
  }
}

void main() {
  group('Flow', () {
    late Flow<String> flow;
    late Map<String, dynamic> shared;
    late List<String> executionLog;

    setUp(() {
      flow = Flow<String>();
      shared = <String, dynamic>{'key': 'value'};
      executionLog = <String>[];
    });

    test('can be instantiated', () {
      expect(flow, isNotNull);
      expect(flow.startNode, isNull);
    });

    test('can be instantiated with start node', () {
      final startNode = TestFlowNode('start', executionLog);
      final flowWithStart = Flow(startNode);

      expect(flowWithStart.startNode, same(startNode));
    });

    test('start sets and returns start node', () {
      final startNode = TestFlowNode('start', executionLog);
      final result = flow.start(startNode);

      expect(result, same(startNode));
      expect(flow.startNode, same(startNode));
    });

    test('getNextNode returns correct successor', () {
      final node1 = TestFlowNode('node1', executionLog);
      final node2 = TestFlowNode('node2', executionLog);

      node1.next(node2, 'success');

      final nextNode = flow.getNextNode(node1, 'success');
      expect(nextNode, same(node2));
    });

    test('getNextNode returns null for non-existent action', () {
      final node1 = TestFlowNode('node1', executionLog);

      final nextNode = flow.getNextNode(node1, 'non_existent');
      expect(nextNode, isNull);
    });

    test('getNextNode warns for non-existent action when successors exist', () {
      final node1 = TestFlowNode('node1', executionLog);
      final node2 = TestFlowNode('node2', executionLog);

      node1.next(node2, 'success');

      // This should print a warning (we can't easily test print output)
      final nextNode = flow.getNextNode(node1, 'failure');
      expect(nextNode, isNull);
    });

    test('internalOrchestrate throws when no start node', () {
      expect(() => flow.internalOrchestrate(shared), throwsStateError);
    });

    test('internalOrchestrate executes single node', () {
      final node1 = TestFlowNode('result1', executionLog);
      flow.start(node1);

      final result = flow.internalOrchestrate(shared);

      expect(result, equals('result1'));
      expect(executionLog, equals(['exec:result1', 'post:result1']));
    });

    test('internalOrchestrate executes node chain', () {
      final node1 = TestFlowNode('result1', executionLog, postResult: 'next');
      final node2 = TestFlowNode('result2', executionLog);

      node1.next(node2, 'next');
      flow.start(node1);

      final result = flow.internalOrchestrate(shared);

      expect(result, equals('result2'));
      expect(
        executionLog,
        equals(['exec:result1', 'post:next', 'exec:result2', 'post:result2']),
      );
    });

    test('internalOrchestrate stops when no successor found', () {
      final node1 = TestFlowNode(
        'result1',
        executionLog,
        postResult: 'unknown_action',
      );
      final node2 = TestFlowNode('result2', executionLog);

      node1.next(node2, 'known_action');
      flow.start(node1);

      final result = flow.internalOrchestrate(shared);

      expect(result, equals('unknown_action'));
      expect(executionLog, equals(['exec:result1', 'post:unknown_action']));
    });

    test('internalOrchestrate merges parameters', () {
      final node1 = _ParameterTestNode('node1', executionLog);
      flow.start(node1);
      flow.setParams({'flow_param': 'flow_value'});

      final customParams = {'custom_param': 'custom_value'};
      flow.internalOrchestrate(shared, customParams);

      // Node should have received merged parameters
      expect(node1.receivedParams, containsPair('flow_param', 'flow_value'));
      expect(
        node1.receivedParams,
        containsPair('custom_param', 'custom_value'),
      );
    });

    test('run executes full flow lifecycle', () {
      final node1 = TestFlowNode('result1', executionLog);
      flow.start(node1);

      final result = flow.run(shared);

      expect(result, equals('result1'));
      expect(executionLog, equals(['exec:result1', 'post:result1']));
    });

    test('exec returns null for Flow', () {
      expect(flow.exec('prep_result'), isNull);
    });

    test('post returns exec result by default', () {
      final result = flow.post(shared, 'prep_result', 'exec_result');
      expect(result, equals('exec_result'));
    });

    test('complex flow with multiple branches', () {
      final node1 = TestFlowNode('node1', executionLog, postResult: 'branch_a');
      final node2a = TestFlowNode(
        'node2a',
        executionLog,
        postResult: 'continue',
      );
      final node2b = TestFlowNode('node2b', executionLog);
      final node3 = TestFlowNode('node3', executionLog);

      // Build flow: node1 -> node2a (branch_a) -> node3 (continue)
      //                  -> node2b (branch_b)
      node1.next(node2a, 'branch_a');
      node1.next(node2b, 'branch_b');
      node2a.next(node3, 'continue');

      flow.start(node1);

      final result = flow.run(shared);

      expect(result, equals('node3'));
      expect(
        executionLog,
        equals([
          'exec:node1',
          'post:branch_a',
          'exec:node2a',
          'post:continue',
          'exec:node3',
          'post:node3',
        ]),
      );
    });

    test('flow inherits BaseNode functionality', () {
      final successor = Flow<String>();
      flow >> successor;

      expect(flow.successors['default'], same(successor));
    });
  });
}

// Helper class to test parameter passing
class _ParameterTestNode extends Node<String> {
  final String _name;
  final List<String> _executionLog;
  Map<String, dynamic> receivedParams = {};

  _ParameterTestNode(this._name, this._executionLog);

  @override
  dynamic prep(Map<String, dynamic> shared) {
    receivedParams = Map.from(params);
    return super.prep(shared);
  }

  @override
  String? exec(dynamic prepRes) {
    _executionLog.add('exec:$_name');
    return _name;
  }
}
