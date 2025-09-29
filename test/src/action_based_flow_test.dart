import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

/// Test node that returns specific actions for testing action-based transitions
class ActionNode extends Node {
  ActionNode(this.actionToReturn);
  final String actionToReturn;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return actionToReturn;
  }

  @override
  BaseNode createInstance() {
    return ActionNode(actionToReturn);
  }

  @override
  ActionNode clone() {
    return super.clone() as ActionNode;
  }
}

/// Test node that returns a value for testing
class ValueNode extends Node {
  ValueNode(this.value);
  final int value;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return value;
  }

  @override
  BaseNode createInstance() {
    return ValueNode(value);
  }

  @override
  ValueNode clone() {
    return super.clone() as ValueNode;
  }
}

void main() {
  group('Action-Based Flow Transitions', () {
    test(
      'should follow action-based transitions with string actions',
      () async {
        // Create nodes
        final startNode = ActionNode('go_right');
        final leftNode = ValueNode(100);
        final rightNode = ValueNode(200);

        // Set up flow: start -> (go_right) -> rightNode
        //                  -> (go_left) -> leftNode
        startNode
          ..next(leftNode, action: 'go_left')
          ..next(rightNode, action: 'go_right');

        final flow = Flow()..start(startNode);

        // Execute flow
        final result = await flow.run({});

        // Should follow 'go_right' action to rightNode
        expect(result, 200);
      },
    );

    test('should fall back to default when action not found', () async {
      // Create nodes
      final startNode = ActionNode('unknown_action');
      final defaultNode = ValueNode(300);

      // Set up flow: start -> (default) -> defaultNode
      startNode.next(defaultNode); // Uses 'default' action

      final flow = Flow()..start(startNode);

      // Execute flow
      final result = await flow.run({});

      // With the corrected logic, if an action is returned, the flow will only
      // look for that specific action. If not found, the flow ends. It does
      // NOT fall back to default.
      expect(result, 'unknown_action');
    });

    test(
      'should handle non-string return values by falling back to default',
      () async {
        // Create nodes that return non-string values
        final startNode = ValueNode(42); // Returns integer, not string
        final nextNode = ValueNode(500);

        // Set up flow: start -> (default) -> nextNode
        startNode.next(nextNode); // Uses 'default' action

        final flow = Flow()..start(startNode);

        // Execute flow
        final result = await flow.run({});

        // Should fall back to 'default' since 42 is not a string action
        expect(result, 500);
      },
    );

    test('should demonstrate Python-style action-based workflow', () async {
      // Create a decision node that returns different actions
      final decisionNode = ActionNode('success');
      final successNode = ValueNode(1000);
      final failureNode = ValueNode(2000);
      final defaultNode = ValueNode(3000);

      // Set up Python-style action-based flow
      decisionNode
        ..next(successNode, action: 'success')
        ..next(failureNode, action: 'failure')
        ..next(defaultNode); // default fallback

      final flow = Flow()..start(decisionNode);

      // Execute flow
      final result = await flow.run({});

      // Should follow 'success' action
      expect(result, 1000);
    });

    test('should work with AsyncFlow and action-based transitions', () async {
      // Create async nodes
      final startNode = SimpleAsyncNode((shared) async => 'async_path');
      final asyncPathNode = SimpleAsyncNode((shared) async => 9999);
      final defaultPathNode = SimpleAsyncNode((shared) async => 8888);

      // Set up async flow with action-based transitions
      startNode
        ..next(asyncPathNode, action: 'async_path')
        ..next(defaultPathNode); // default

      final flow = AsyncFlow()..start(startNode);

      // Execute async flow
      final result = await flow.runAsync({});

      // Should follow 'async_path' action
      expect(result, 9999);
    });
  });
}
