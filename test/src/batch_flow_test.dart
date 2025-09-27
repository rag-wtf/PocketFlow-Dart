import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class MultiplyNode extends Node {
  MultiplyNode(this.factor);
  final int factor;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared['value'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return (prepResult as int) * factor;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['value'] = execResult;
    return super.post(shared, prepResult, execResult);
  }

  @override
  Node clone() {
    return MultiplyNode(factor)..params = Map.from(params);
  }
}

class AddNode extends Node {
  AddNode(this.valueToAdd);
  final int valueToAdd;

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared['value'];
  }

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return (prepResult as int) + valueToAdd;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['value'] = execResult;
    return super.post(shared, prepResult, execResult);
  }

  @override
  Node clone() {
    return AddNode(valueToAdd)..params = Map.from(params);
  }
}

void main() {
  group('BatchFlow', () {
    test('should run a flow over a batch of inputs', () async {
      final multiplyNode = MultiplyNode(2);
      final addNode = AddNode(1);

      final flow = BatchFlow<int, int>([multiplyNode, addNode]);
      final inputs = [1, 2, 3];
      final outputs = await flow.run({'items': inputs});

      expect(outputs, equals([3, 5, 7]));
    });
  });
}
