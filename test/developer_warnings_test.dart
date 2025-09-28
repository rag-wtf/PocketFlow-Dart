import 'dart:async';

import 'package:pocketflow/pocketflow.dart';
import 'package:pocketflow/src/base_node.dart';
import 'package:test/test.dart';

class TestNode extends BaseNode {
  @override
  BaseNode clone() {
    return TestNode();
  }
}

void main() {
  test('should log a warning when a successor is overwritten', () async {
    final logs = <String>[];
    await runZoned(
      () async {
        final nodeA = TestNode();
        final nodeB = TestNode();
        final nodeC = TestNode();

        nodeA
          ..next(nodeB)
          ..next(nodeC);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(
      logs.any((log) => log.contains('Overwriting existing successor')),
      isTrue,
    );
  });

  test(
    'should log a warning when run() is called on a node with successors '
    'outside of a Flow',
    () async {
      final logs = <String>[];
      await runZoned(
        () async {
          final nodeA = TestNode();
          final nodeB = TestNode();
          nodeA.next(nodeB);

          await nodeA.run({});
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            logs.add(line);
          },
        ),
      );

      expect(
        logs.any(
          (log) => log.contains(
            'Calling run() on a node with successors has no effect on '
            'flow execution',
          ),
        ),
        isTrue,
      );
    },
  );
}
