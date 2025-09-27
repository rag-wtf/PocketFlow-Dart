import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A concrete implementation of BaseNode for testing purposes.
class _TestNode extends BaseNode {
  _TestNode();

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    return {'value': 'test'};
  }

  @override
  BaseNode clone() {
    final cloned = _TestNode();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class _AddValueNode1 extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    params['value'] = (params['value'] as int) + 1;
    return params;
  }

  @override
  Node clone() {
    final cloned = _AddValueNode1();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class _AddValueNode2 extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    params['value'] = (params['value'] as int) + 2;
    return params;
  }

  @override
  Node clone() {
    final cloned = _AddValueNode2();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

class _AddValueNode3 extends Node {
  @override
  Future<dynamic> exec(dynamic prepResult) async {
    params['value'] = (params['value'] as int) + 3;
    return params;
  }

  @override
  Node clone() {
    final cloned = _AddValueNode3();
    cloned.name = name;
    cloned.params = Map.from(params);
    return cloned;
  }
}

void main() {
  group('pocketflow', () {
    test('should export BaseNode', () {
      final node = _TestNode();
      expect(node, isA<BaseNode>());
    });

    test('should export Node', () {
      final node = Node();
      expect(node, isA<Node>());
    });

    test('should export Flow', () {
      final flow = Flow();
      expect(flow, isA<Flow>());
    });

    // test('should support operator overloading', () {
    //   final node1 = _AddValueNode1();
    //   final node2 = _AddValueNode2();
    //   final node3 = _AddValueNode3();

    //   final flow = node1 >> node2 - node3;

    //   expect(flow, isA<Flow>());
    // });
  });
}
