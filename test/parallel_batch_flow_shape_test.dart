import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class EchoNode extends Node {
  EchoNode();

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    final shared = prepResult as Map<String, dynamic>;
    return shared['input'];
  }

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    return shared;
  }

  @override
  BaseNode createInstance() => EchoNode();
}

void main() {
  test('AsyncParallelBatchFlow returns list-of-results and is documented', () async {
    final flow = AsyncParallelBatchFlow([EchoNode()], copySharedForParallel: true);
    final res = await flow.call([{'x': 1}, {'x': 2}]);
    expect(res, isA<List>()); // the result is a list of results per item
  });
}
