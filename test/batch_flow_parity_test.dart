import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class RecordingNode extends Node {
  RecordingNode();

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    // record current params into shared.traceParams for test
    final trace = shared.putIfAbsent('traceBatch', () => <dynamic>[]) as List;

    trace.add(Map<String, dynamic>.from(params));
    return shared;
  }

  @override
  Future<dynamic> exec(dynamic prepRes) async {
    return null;
  }

  @override
  BaseNode createInstance() => RecordingNode();
}

void main() {
  test(
    'BatchFlow returns post(..., exec_res=null) and respects params',
    () async {
      final shared = <String, dynamic>{
        'items': [
          {'x': 1},
          {'x': 2},
          {'x': 3},
        ],
        'traceBatch': <dynamic>[],
      };
      final node = RecordingNode();
      final flow = BatchFlow<dynamic, dynamic>([node]);

      final out = await flow.run(shared);
      // Python BatchFlow.post by default returns exec_res which was None
      expect(out, isNull);

      final trace = shared['traceBatch'] as List<dynamic>;
      expect(trace.length, equals(3));
      // check first recorded param has 'x' == 1 (nested under 'value')
      expect(((trace[0] as Map)['value'] as Map)['x'], equals(1));
    },
  );
}
