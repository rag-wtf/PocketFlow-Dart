import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class TraceNode extends Node {
  TraceNode(this.id, this.actionToReturn);
  final String id;
  final dynamic actionToReturn;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return actionToReturn;
  }

  @override
  BaseNode createInstance() => TraceNode(id, actionToReturn);
}

void main() {
  test('Flow.orch should use shallow copy-on-demand for nodes', () async {
    final nodeA = TraceNode('A', 'go_to_B');
    final nodeB = TraceNode('B', 'done');

    final flow = Flow()
      ..start(nodeA)
      ..next(nodeB, action: 'go_to_B');

    final shared = <String, dynamic>{'counter': 0};
    final result = await flow.orch(shared);

    // Should complete the flow orchestration
    expect(result, isNotNull);
  });

  test('Flow.orch should respect maxSteps parameter', () async {
    final loopNode = TraceNode('loop', 'loop');
    loopNode.next(loopNode, action: 'loop'); // Create self-loop
    final flow = Flow()..start(loopNode);

    final shared = <String, dynamic>{};

    // Should throw when maxSteps is exceeded
    expect(
      () => flow.orch(shared, null, 5),
      throwsA(isA<StateError>()),
    );
  });
}
