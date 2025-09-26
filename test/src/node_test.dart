import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// --- Node Definitions from test_flow_basic.py ---

class NumberNode extends Node {
  NumberNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = number;
  }
}

class AddNode extends Node {
  AddNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) + number;
  }
}

class MultiplyNode extends Node {
  MultiplyNode(this.number);
  final int number;

  @override
  void prep(Map<String, dynamic> sharedStorage) {
    sharedStorage['current'] = (sharedStorage['current'] as int? ?? 0) * number;
  }
}

// --- AsyncNode Definitions from test_async_flow.py ---

// class AsyncNumberNode extends AsyncNode {
//   final int number;
//   AsyncNumberNode(this.number);
//
//   @override
//   Future<dynamic> prepAsync(Map<String, dynamic> sharedStorage) async {
//     sharedStorage['current'] = number;
//     return 'set_number';
//   }
//
//   @override
//   Future<dynamic> postAsync(
//     Map<String, dynamic> sharedStorage,
//     dynamic prepResult,
//   ) async {
//     // In Python, this was asyncio.sleep(0.01)
//     await Future.delayed(const Duration(milliseconds: 10));
//     return 'number_set';
//   }
// }
//
// class AsyncIncrementNode extends AsyncNode {
//   @override
//   Future<dynamic> prepAsync(Map<String, dynamic> sharedStorage) async {
//     sharedStorage['current'] = (sharedStorage['current'] ?? 0) + 1;
//     return 'incremented';
//   }
//
//   @override
//   Future<dynamic> postAsync(
//     Map<String, dynamic> sharedStorage,
//     dynamic prepResult,
//   ) async {
//     await Future.delayed(const Duration(milliseconds: 10));
//     return 'done';
//   }
// }

void main() {
  group('Node', () {
    test('NumberNode sets the initial value correctly', () {
      final node = NumberNode(42);
      final storage = <String, dynamic>{};
      node.call(storage);
      expect(storage['current'], 42);
    });

    test('AddNode adds to the value correctly', () {
      final node = AddNode(10);
      final storage = <String, dynamic>{'current': 5};
      node.call(storage);
      expect(storage['current'], 15);
    });

    test('MultiplyNode multiplies the value correctly', () {
      final node = MultiplyNode(3);
      final storage = <String, dynamic>{'current': 5};
      node.call(storage);
      expect(storage['current'], 15);
    });
  });

  // group('AsyncNode', () {
  //   test('AsyncNumberNode works when called directly', () async {
  //     final node = AsyncNumberNode(42);
  //     final storage = <String, dynamic>{};
  //     final condition = await node.runAsync(storage);
  //     expect(storage['current'], 42);
  //     expect(condition, 'number_set');
  //   });
  //
  //   test('AsyncIncrementNode works when called directly', () async {
  //     final node = AsyncIncrementNode();
  //     final storage = <String, dynamic>{'current': 10};
  //     final condition = await node.runAsync(storage);
  //     expect(storage['current'], 11);
  //     expect(condition, 'done');
  //   });
  // });
}
