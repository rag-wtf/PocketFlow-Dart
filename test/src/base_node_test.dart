import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// A mock implementation of BaseNode to test its functionalities.
class MockNode extends BaseNode {
  bool prepCalled = false;
  bool postCalled = false;
  dynamic prepResult = 'prep_result';
  dynamic postResult;
  dynamic receivedPrepResult;

  @override
  dynamic prep(Map<String, dynamic> sharedStorage) {
    prepCalled = true;
    return prepResult;
  }

  @override
  dynamic post(Map<String, dynamic> sharedStorage, dynamic prepResult) {
    postCalled = true;
    receivedPrepResult = prepResult;
    return postResult;
  }
}

void main() {
  group('BaseNode', () {
    late MockNode node;
    late Map<String, dynamic> sharedStorage;

    setUp(() {
      node = MockNode();
      sharedStorage = {};
    });

    test('call should execute prep and post methods in order', () {
      node(sharedStorage);
      expect(node.prepCalled, isTrue, reason: 'prep should be called');
      expect(node.postCalled, isTrue, reason: 'post should be called');
    });

    test('call should pass prep result to post', () {
      node(sharedStorage);
      expect(node.receivedPrepResult, equals(node.prepResult),
          reason: 'post should receive the result from prep');
    });

    test('call should return the result of the post method', () {
      node.postResult = 'test_result';
      final result = node(sharedStorage);
      expect(result, equals('test_result'),
          reason: 'call should return the result from post');
    });
  });
}