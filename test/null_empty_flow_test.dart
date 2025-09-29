import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class NoopNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async => null;

  @override
  BaseNode createInstance() => NoopNode();
}

void main() {
  test('Flow should handle null return values gracefully', () async {
    final node = NoopNode();
    final flow = Flow()..start(node);

    final shared = <String, dynamic>{};
    final result = await flow.run(shared);

    expect(result, isNull);
  });

  test('Empty flow should throw StateError', () async {
    final flow = Flow();
    final shared = <String, dynamic>{};

    // Flow with no nodes should throw StateError
    expect(() => flow.run(shared), throwsA(isA<StateError>()));
  });

  test('Flow with null shared state should work', () async {
    final node = NoopNode();
    final flow = Flow()..start(node);

    final result = await flow.run(<String, dynamic>{});
    expect(result, isNull);
  });
}
