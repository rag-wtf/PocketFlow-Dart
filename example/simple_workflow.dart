import 'package:pocketflow/pocketflow.dart';

/// Example demonstrating a simple text processing workflow
/// 
/// This example shows how to:
/// 1. Create custom nodes that extend BaseNode
/// 2. Chain nodes together using the >> operator
/// 3. Create and run a Flow
/// 4. Handle shared data between nodes

/// A node that processes text input
class TextProcessorNode extends BaseNode<String> {
  final String operation;
  
  TextProcessorNode(this.operation);
  
  @override
  dynamic prep(Map<String, dynamic> shared) {
    // Get input from shared data or parameters
    return shared['input'] ?? params['input'] ?? '';
  }
  
  @override
  String? exec(dynamic prepRes) {
    final text = prepRes as String;
    switch (operation) {
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
    // Store result in shared data for next node
    shared['processed_text'] = execRes;
    return 'default'; // Continue to next node
  }
}

/// A node that formats the processed text
class FormatterNode extends BaseNode<String> {
  final String format;
  
  FormatterNode(this.format);
  
  @override
  dynamic prep(Map<String, dynamic> shared) {
    // Get the processed text from previous node
    return shared['processed_text'] ?? '';
  }
  
  @override
  String? exec(dynamic prepRes) {
    final text = prepRes as String;
    switch (format) {
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
    // Store final result
    shared['final_result'] = execRes;
    return execRes;
  }
}

void main() {
  print('PocketFlow Dart - Simple Workflow Example\n');
  
  // Create nodes
  final processor = TextProcessorNode('uppercase');
  final formatter = FormatterNode('brackets');
  
  // Chain nodes together
  processor >> formatter;
  
  // Create and configure flow
  final flow = Flow<String>();
  flow.start(processor);
  
  // Prepare shared data
  final shared = <String, dynamic>{
    'input': 'hello world',
  };
  
  print('Input: ${shared['input']}');
  
  // Run the workflow
  final result = flow.run(shared);
  
  print('Final result: ${shared['final_result']}');
  print('Flow returned: $result');
  
  // Example output:
  // Input: hello world
  // Final result: [HELLO WORLD]
  // Flow returned: [HELLO WORLD]
  
  print('\n--- Conditional Workflow Example ---\n');
  
  // Example with conditional branching
  final validator = ValidationNode(10); // Max 10 characters
  final successFormatter = FormatterNode('quotes');
  final errorHandler = ErrorHandlerNode();
  
  // Set up conditional branches
  (validator - 'valid') >> successFormatter;
  (validator - 'invalid') >> errorHandler;
  
  final conditionalFlow = Flow<String>();
  conditionalFlow.start(validator);
  
  // Test with short text (valid)
  final shared1 = <String, dynamic>{'input': 'short'};
  print('Testing with short text: ${shared1['input']}');
  conditionalFlow.run(shared1);
  print('Result: ${shared1['final_result']}\n');
  
  // Test with long text (invalid)
  final shared2 = <String, dynamic>{'input': 'this text is too long'};
  print('Testing with long text: ${shared2['input']}');
  conditionalFlow.run(shared2);
  print('Result: ${shared2['final_result']}');
}

/// A validation node that checks text length
class ValidationNode extends BaseNode<bool> {
  final int maxLength;
  
  ValidationNode(this.maxLength);
  
  @override
  dynamic prep(Map<String, dynamic> shared) {
    return shared['input'] ?? '';
  }
  
  @override
  bool? exec(dynamic prepRes) {
    final text = prepRes as String;
    return text.length <= maxLength;
  }
  
  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, bool? execRes) {
    return execRes == true ? 'valid' : 'invalid';
  }
}

/// An error handler node
class ErrorHandlerNode extends BaseNode<String> {
  @override
  String? exec(dynamic prepRes) {
    return 'Error: Text too long';
  }
  
  @override
  dynamic post(Map<String, dynamic> shared, dynamic prepRes, String? execRes) {
    shared['final_result'] = execRes;
    return execRes;
  }
}
