import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class CheckParamsNode extends Node {
  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    // Merge parameters with precedence: shared > flow > node
    final mergedParams = <String, dynamic>{}
      ..addAll(params) // Node params (lowest precedence)
      // Flow params are already added to node params by Flow.orch
      ..addAll(shared); // Shared params (highest precedence)
    return mergedParams;
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return prepResult;
  }

  @override
  BaseNode createInstance() => CheckParamsNode();
}

void main() {
  test('Parameters should follow precedence: explicit > flow > node', () async {
    final node = CheckParamsNode();
    node.params['node_param'] = 'node_value';
    node.params['shared_param'] = 'node_shared';

    final flow = Flow();
    flow.params['flow_param'] = 'flow_value';
    flow.params['shared_param'] = 'flow_shared';
    flow.start(node);

    final shared = <String, dynamic>{
      'explicit_param': 'explicit_value',
      'shared_param': 'explicit_shared',
    };

    final result = await flow.run(shared);
    final resultParams = result as Map<String, dynamic>;

    // Explicit params should take precedence
    expect(resultParams['explicit_param'], equals('explicit_value'));
    expect(resultParams['shared_param'], equals('explicit_shared'));

    // Flow params should be included when not overridden
    expect(resultParams['flow_param'], equals('flow_value'));

    // Node params should be included when not overridden
    expect(resultParams['node_param'], equals('node_value'));
  });
}
