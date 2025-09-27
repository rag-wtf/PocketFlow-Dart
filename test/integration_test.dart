import 'package:pocketflow/pocketflow.dart';
import 'package:test/test.dart';

// Example workflow nodes for integration testing

/// A node that processes text input
class TextProcessorNode extends Node<String> {
  final String _operation;

  TextProcessorNode(this._operation);

  @override
  String? exec(dynamic prepRes) {
    final text = prepRes as String? ?? '';
    switch (_operation) {
      case 'uppercase':
        return text.toUpperCase();
      case 'lowercase':
        return text.toLowerCase();
      case 'reverse':
        return text.split('').reversed.join('');
      default:
        return text;
    }
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    shared['last_result'] = execRes;
    return 'default'; // Use 'default' to match the default successor
  }
}

/// A node that validates text length
class ValidationNode extends Node<bool> {
  final int _maxLength;

  ValidationNode(this._maxLength);

  @override
  bool? exec(dynamic prepRes) {
    final text = prepRes as String? ?? '';
    return text.length <= _maxLength;
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, bool? execRes) {
    shared['validation_result'] = execRes;
    return execRes == true ? 'valid' : 'invalid';
  }
}

/// A node that formats output
class FormatterNode extends Node<String> {
  final String _format;

  FormatterNode(this._format);

  @override
  dynamic prep(Map<String, dynamic> shared) {
    return shared['last_result'] as String? ?? '';
  }

  @override
  String? exec(dynamic prepRes) {
    final text = prepRes as String;
    switch (_format) {
      case 'brackets':
        return '[$text]';
      case 'quotes':
        return '"$text"';
      case 'asterisk':
        return '*$text*';
      default:
        return text;
    }
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    shared['final_result'] = execRes;
    return execRes;
  }
}

/// A node that handles errors
class ErrorHandlerNode extends Node<String> {
  @override
  String? exec(dynamic prepRes) {
    return 'Error handled: Processing failed';
  }

  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    shared['final_result'] = execRes;
    return execRes;
  }
}

/// A batch processing node for multiple texts
class BatchTextProcessorNode extends BatchNode<String> {
  final String _operation;

  BatchTextProcessorNode(this._operation);

  @override
  String? execSingle(dynamic prepRes) {
    final text = prepRes as String? ?? '';
    switch (_operation) {
      case 'uppercase':
        return text.toUpperCase();
      case 'lowercase':
        return text.toLowerCase();
      case 'trim':
        return text.trim();
      default:
        return text;
    }
  }

  @override
  dynamic post(
    Map<String, dynamic> shared,
    dynamic prepRes,
    List<String?>? execRes,
  ) {
    shared['batch_results'] = execRes;
    return execRes;
  }
}

void main() {
  group('Integration Tests', () {
    test('Simple linear workflow', () {
      // Create a simple workflow: input -> uppercase -> format with brackets
      final processor = _CustomTextProcessorNode('uppercase');
      final formatter = FormatterNode('brackets');

      // Chain the nodes
      processor >> formatter;

      // Create and run the flow
      final flow = Flow<String>();
      flow.start(processor);

      final shared = <String, dynamic>{};

      flow.run(shared);

      expect(shared['final_result'], equals('[HELLO WORLD]'));
    });

    test('Conditional workflow with validation', () {
      // Create workflow with validation branch
      final validator = ValidationNode(10); // Max 10 characters
      final successFormatter = FormatterNode('quotes');
      final errorHandler = ErrorHandlerNode();

      // Set up conditional flow
      (validator - 'valid') >> successFormatter;
      (validator - 'invalid') >> errorHandler;

      final flow = Flow<String>();
      flow.start(validator);

      // Test with valid input
      final shared1 = <String, dynamic>{};
      validator.setParams({'input': 'short'});

      final customValidator1 = _CustomValidationNode(10);
      final customSuccessFormatter = FormatterNode('quotes');
      final customErrorHandler = ErrorHandlerNode();

      (customValidator1 - 'valid') >> customSuccessFormatter;
      (customValidator1 - 'invalid') >> customErrorHandler;

      final customFlow1 = Flow<String>();
      customFlow1.start(customValidator1);

      final result1 = customFlow1.run(shared1);
      expect(shared1['final_result'], equals('"short"'));

      // Test with invalid input
      final shared2 = <String, dynamic>{};
      final customValidator2 = _CustomValidationNode(10);
      final customSuccessFormatter2 = FormatterNode('quotes');
      final customErrorHandler2 = ErrorHandlerNode();

      (customValidator2 - 'valid') >> customSuccessFormatter2;
      (customValidator2 - 'invalid') >> customErrorHandler2;

      final customFlow2 = Flow<String>();
      customFlow2.start(customValidator2);
      customValidator2.setParams({'input': 'this is too long'});

      final result2 = customFlow2.run(shared2);
      expect(
        shared2['final_result'],
        equals('Error handled: Processing failed'),
      );
    });

    test('Batch processing workflow', () {
      final batchProcessor = BatchTextProcessorNode('uppercase');

      final flow = Flow<List<String?>>();
      flow.start(batchProcessor);

      final shared = <String, dynamic>{};

      // Override prep to provide batch data
      final customBatchProcessor = _CustomBatchTextProcessorNode('uppercase');
      final customFlow = Flow<List<String?>>();
      customFlow.start(customBatchProcessor);

      final result = customFlow.run(shared);

      expect(shared['batch_results'], equals(['HELLO', 'WORLD', 'TEST']));
    });

    test('Complex multi-step workflow', () {
      // Create a complex workflow with multiple processing steps
      final processor1 = _CustomTextProcessorNode('lowercase');
      final processor2 = TextProcessorNode('reverse');
      final validator = _CustomValidationNode(20);
      final successFormatter = FormatterNode('asterisk');
      final errorHandler = ErrorHandlerNode();

      // Chain the workflow
      processor1 >> processor2;
      processor2 >> validator;
      (validator - 'valid') >> successFormatter;
      (validator - 'invalid') >> errorHandler;

      final flow = Flow<String>();
      flow.start(processor1);

      final shared = <String, dynamic>{};

      final result = flow.run(shared);

      // Input: "Hello World" -> lowercase: "hello world" -> reverse: "dlrow olleh" -> valid -> format: "*dlrow olleh*"
      expect(shared['final_result'], equals('*dlrow olleh*'));
    });
  });
}

// Custom implementations for integration tests

class _CustomTextProcessorNode extends TextProcessorNode {
  _CustomTextProcessorNode(super.operation);

  @override
  dynamic prep(Map<String, dynamic> shared) {
    return params['input'] ?? 'Hello World';
  }
}

class _CustomValidationNode extends ValidationNode {
  _CustomValidationNode(super.maxLength);

  @override
  dynamic prep(Map<String, dynamic> shared) {
    return shared['last_result'] ?? params['input'] ?? '';
  }
}

class _CustomBatchTextProcessorNode extends BatchTextProcessorNode {
  _CustomBatchTextProcessorNode(super.operation);

  @override
  dynamic prep(Map<String, dynamic> shared) {
    return ['hello', 'world', 'test'];
  }
}
