import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A helper async function for testing.
Future<int> asyncAdd(int a, int b) async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return a + b;
}

// A test node that increments a value and returns it.
class _AsyncTestCloneNode extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    params['value'] = (params['value'] as int) + 1;
    return params;
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    // Return the value from the params so we can check it in tests.
    return (execResult as Map<String, dynamic>)['value'];
  }

  @override
  BaseNode createInstance() {
    return _AsyncTestCloneNode();
  }

  @override
  _AsyncTestCloneNode clone() {
    return super.clone() as _AsyncTestCloneNode;
  }
}

void main() {
  group('AsyncFlow', () {
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      sharedStorage = {};
    });

    test('should execute a simple async flow', () async {
      final addNode1 = SimpleAsyncNode((dynamic storage) async {
        (storage as Map<String, dynamic>)['result'] = await asyncAdd(10, 12);
        return storage;
      });
      final addNode2 = SimpleAsyncNode((dynamic storage) async {
        (storage as Map<String, dynamic>)['result'] = await asyncAdd(5, 5);
        return storage;
      });

      final flow = AsyncFlow();
      flow.start(addNode1).next(addNode2);

      await flow.run(sharedStorage);
      expect(sharedStorage['result'], 10);
    });

    group('.clone()', () {
      test('should create a deep copy of the graph', () async {
        final nodeA = _AsyncTestCloneNode()..params['value'] = 1;
        final nodeB = _AsyncTestCloneNode()..params['value'] = 10;
        final nodeC = _AsyncTestCloneNode()..params['value'] = 100;

        // Original flow is A -> B
        final originalFlow = AsyncFlow();
        originalFlow.start(nodeA).next(nodeB);

        // Clone the flow
        final clonedFlow = originalFlow.clone();

        // Modify the original flow's graph to A -> C
        nodeA.next(nodeC);

        // Run the original flow. It should execute A -> C and return 101.
        var result = await originalFlow.run({});
        expect(result, 101);

        // Run the cloned flow. It should still execute A -> B and return 11.
        result = await clonedFlow.run({});
        expect(result, 11);
      });
    });
  });

  group('AsyncFlow default implementations', () {
    test('postAsync should return execResult by default', () async {
      final flow = _ConcreteAsyncFlow(
        start: SimpleAsyncNode((_) async => 'exec_result'),
      );
      final result = await flow.runAsync({});
      expect(result, 'exec_result');
    });

    test('execFallbackAsync should return null by default', () async {
      final flow = _ConcreteAsyncFlow();
      final result = await flow.execFallbackAsync(null, Exception('test'));
      expect(result, isNull);
    });
  });
}

class _ConcreteAsyncFlow extends AsyncFlow {
  _ConcreteAsyncFlow({super.start});
}
