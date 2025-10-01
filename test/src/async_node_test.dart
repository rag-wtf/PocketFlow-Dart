import 'dart:async';

import 'package:pocketflow/src/async_node.dart';
import 'package:pocketflow/src/node.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncNode', () {
    test('should execute with default implementations', () async {
      final node = AsyncNode();
      final result = await node.run({});
      expect(result, isNull);
    });

    test(
      '''
should call execFallbackAsync when execAsync fails and fallback is implemented''',
      () async {
        final node = _FailingWithFallbackAsyncNode();
        final result = await node.run({});
        expect(result, 'fallback');
      },
    );

    test(
      '''
should rethrow error when execAsync fails and fallback is not implemented''',
      () async {
        final node = _FailingWithoutFallbackAsyncNode();
        expect(node.run({}), throwsException);
      },
    );

    test('should rethrow non-exception errors immediately', () async {
      final node = _FailingWithNonExceptionNode();
      expect(node.run({}), throwsA(isA<Exception>()));
    });

    test(
      'should call prepAsync and postAsync with default execAsync',
      () async {
        final node = _PrepPostAsyncNode();
        final shared = <String, dynamic>{'value': 10};
        final result = await node.run(shared);
        expect(result, 20);
        expect(shared['value'], 20);
      },
    );

    test('runAsync should log a warning if the node has successors', () async {
      final logs = <String>[];
      final node = AsyncNode();
      final successor = AsyncNode();
      node
        ..next(successor)
        // Assign the print function to the node's log so it can be captured.
        ..log = print;

      await runZoned(
        () => node.runAsync({}),
        zoneSpecification: ZoneSpecification(
          print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
            logs.add(line);
          },
        ),
      );

      expect(
        logs.any(
          (log) => log.contains(
            '''
Warning: Calling runAsync() on a node with successors has no effect''',
          ),
        ),
        isTrue,
      );
    });

    test(
      'clone should create a new instance with the same properties',
      () async {
        final node = AsyncNode(maxRetries: 3, wait: const Duration(seconds: 1));
        final clonedNode = node.clone();

        expect(clonedNode, isA<AsyncNode>());
        expect(clonedNode, isNot(same(node)));
        expect(clonedNode.maxRetries, 3);
        expect(clonedNode.wait, const Duration(seconds: 1));
      },
    );

    test('run method should delegate to runAsync', () async {
      final node = _TestRunAsyncNode();
      await node.run({});
      expect(node.runAsyncCalled, isTrue);
    });
  });

  group('SimpleAsyncNode', () {
    test('should inherit from Node', () {
      final asyncNode = SimpleAsyncNode((_) async => null);
      expect(asyncNode, isA<Node>());
    });

    test(
      'should execute the async function provided in the constructor',
      () async {
        const expectedResult = 'test_result';
        final asyncNode = SimpleAsyncNode((_) async => expectedResult);
        final result = await asyncNode.execAsync(null);
        expect(result, equals(expectedResult));
      },
    );

    test(
      'should pass the prepResult to the async function in the constructor',
      () async {
        const prepData = {'key': 'value'};
        final asyncNode = SimpleAsyncNode((dynamic prepResult) async {
          expect(prepResult, equals(prepData));
          return 'done';
        });
        await asyncNode.execAsync(prepData);
      },
    );

    test(
      'clone() should create a new instance with the same exec function',
      () async {
        const expectedResult = 'cloned_result';
        final originalNode = SimpleAsyncNode((_) async => expectedResult)
          ..name = 'Original';

        final clonedNode = originalNode.clone();

        expect(clonedNode, isA<SimpleAsyncNode>());
        expect(clonedNode.name, equals('Original'));
        expect(clonedNode, isNot(same(originalNode)));

        final result = await clonedNode.execAsync(null);
        expect(result, equals(expectedResult));
      },
    );
  });
}

class _FailingWithFallbackAsyncNode extends AsyncNode {
  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    throw Exception('test');
  }

  @override
  Future<dynamic> execFallbackAsync(dynamic prepResult, Exception error) async {
    return 'fallback';
  }
}

class _FailingWithoutFallbackAsyncNode extends AsyncNode {
  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    throw Exception('test');
  }
}

class _FailingWithNonExceptionNode extends AsyncNode {
  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    throw Exception('a string error');
  }
}

class _PrepPostAsyncNode extends AsyncNode {
  @override
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return shared['value'] as int;
  }

  @override
  Future<dynamic> postAsync(
    Map<String, dynamic> shared,
    dynamic prepResult,
    dynamic execResult,
  ) async {
    shared['value'] = (prepResult as int) * 2;
    return shared['value'];
  }
}

class _TestRunAsyncNode extends AsyncNode {
  bool runAsyncCalled = false;

  @override
  Future<dynamic> runAsync(Map<String, dynamic> shared) {
    runAsyncCalled = true;
    return super.runAsync(shared);
  }
}
