import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

void main() {
  group('pocketflow', () {
    test('should export BaseNode', () {
      expect(BaseNode, isA<Type>());
    });

    test('should export Node', () {
      expect(Node, isA<Type>());
    });

    test('should export Flow', () {
      expect(Flow, isA<Type>());
    });
  });
}