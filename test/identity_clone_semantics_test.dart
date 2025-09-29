import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class IdentityNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async => null;

  @override
  BaseNode createInstance() => IdentityNode();
}

void main() {
  test('Node clone should create distinct instances', () async {
    final original = IdentityNode();
    original.name = 'original';
    original.params['test'] = 'value';
    
    final cloned = original.clone();
    
    // Should be different instances
    expect(identical(original, cloned), isFalse);
    
    // Should have same values
    expect(cloned.name, equals('original'));
    expect(cloned.params['test'], equals('value'));
    
    // Should be independent
    cloned.name = 'cloned';
    cloned.params['test'] = 'new_value';
    
    expect(original.name, equals('original'));
    expect(original.params['test'], equals('value'));
  });

  test('Flow clone should create deep copy', () async {
    final node1 = IdentityNode();
    node1.name = 'node1';
    
    final node2 = IdentityNode();
    node2.name = 'node2';
    
    final originalFlow = Flow();
    originalFlow.start(node1);
    originalFlow.next(node2);
    originalFlow.params['flow_param'] = 'flow_value';
    
    final clonedFlow = originalFlow.clone();
    
    // Should be different instances
    expect(identical(originalFlow, clonedFlow), isFalse);
    
    // Should have same structure but independent nodes
    expect(clonedFlow.params['flow_param'], equals('flow_value'));
    
    // Modifying cloned flow should not affect original
    clonedFlow.params['flow_param'] = 'new_value';
    expect(originalFlow.params['flow_param'], equals('flow_value'));
  });

  test('Clone semantics should preserve node relationships', () async {
    final node1 = IdentityNode();
    final node2 = IdentityNode();
    
    final flow = Flow();
    flow.start(node1);
    flow.next(node2);
    
    final clonedFlow = flow.clone();
    
    // Both flows should execute independently
    final shared1 = <String, dynamic>{'test': 'original'};
    final shared2 = <String, dynamic>{'test': 'cloned'};
    
    final result1 = await flow.run(shared1);
    final result2 = await clonedFlow.run(shared2);
    
    // Should complete without interference
    expect(result1, isNull);
    expect(result2, isNull);
  });
}
