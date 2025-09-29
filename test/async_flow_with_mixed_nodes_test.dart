import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

class SyncRecorder extends Node {
  SyncRecorder(this.id);
  final String id;

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return 'next'; // Return action to transition to next node
  }

  @override
  BaseNode createInstance() => SyncRecorder(id);
}

class AsyncRecorder extends AsyncNode {
  AsyncRecorder(this.id);
  final String id;

  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return 'async_$id';
  }

  @override
  BaseNode createInstance() => AsyncRecorder(id);
}

void main() {
  test('AsyncFlow should handle mixed sync and async nodes', () async {
    final syncNode = SyncRecorder('sync1');
    final asyncNode = AsyncRecorder('async1');

    syncNode.next(asyncNode, action: 'next');
    final flow = AsyncFlow()..start(syncNode);

    final shared = <String, dynamic>{};
    final result = await flow.run(shared);

    // Should complete with async node result
    expect(result, equals('async_async1'));
  });

  test('AsyncFlow should orchestrate mixed node types correctly', () async {
    final syncNode = SyncRecorder('sync');
    final asyncNode = AsyncRecorder('async');

    syncNode.next(asyncNode, action: 'next');
    final flow = AsyncFlow()..start(syncNode);

    final shared = <String, dynamic>{};
    final result = await flow.orchAsync(shared);

    // Should handle both sync and async nodes in orchestration
    expect(result, isNotNull);
  });
}
