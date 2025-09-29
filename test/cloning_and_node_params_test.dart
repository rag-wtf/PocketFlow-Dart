import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class MutatingNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    params['mutated'] = true;
    return 'mutated';
  }

  @override
  BaseNode createInstance() => MutatingNode();
}

void main() {
  test('Node cloning should create independent parameter copies', () async {
    final original = MutatingNode();
    original.params['initial'] = 'value';
    
    final cloned = original.clone();
    
    // Modify cloned params
    cloned.params['cloned_param'] = 'cloned_value';
    
    // Original should not be affected
    expect(original.params.containsKey('cloned_param'), isFalse);
    expect(cloned.params['initial'], equals('value'));
  });

  test('Node execution should not affect original after cloning', () async {
    final original = MutatingNode();
    final cloned = original.clone();
    
    final shared = <String, dynamic>{};
    await cloned.run(shared);
    
    // Original params should not be mutated
    expect(original.params.containsKey('mutated'), isFalse);
    expect(cloned.params['mutated'], isTrue);
  });
}
