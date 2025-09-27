# PocketFlow Dart

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A minimalist LLM framework, ported from Python to Dart. PocketFlow provides a lightweight, graph-based workflow system for building LLM applications with support for node chaining, conditional branching, batch processing, and async execution.

## Features

- **🔗 Node-based Workflows**: Create complex workflows by chaining nodes together
- **🔀 Conditional Branching**: Route execution based on node results
- **📦 Batch Processing**: Process collections of data efficiently
- **⚡ Async Support**: Full async/await support for non-blocking operations
- **🎯 Type Safe**: Built with Dart's sound null safety
- **🪶 Lightweight**: Zero external dependencies for the core library
- **🔧 Extensible**: Easy to extend with custom node types

## Quick Start

```dart
import 'package:pocketflow/pocketflow.dart';

// Create a simple text processing node
class UppercaseNode extends BaseNode<String> {
  @override
  String? exec(dynamic prepRes) {
    return (prepRes as String).toUpperCase();
  }
}

// Create a formatting node
class BracketNode extends BaseNode<String> {
  @override
  String? exec(dynamic prepRes) {
    return '[$prepRes]';
  }
}

void main() {
  // Chain nodes together
  final uppercase = UppercaseNode();
  final bracket = BracketNode();
  uppercase >> bracket;

  // Create and run flow
  final flow = Flow<String>();
  flow.start(uppercase);

  final shared = {'input': 'hello world'};
  final result = flow.run(shared);
  // Output: [HELLO WORLD]
}
```

## Installation 💻

**❗ In order to start using PocketFlow you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add pocketflow
```

## Core Concepts

### BaseNode
The foundation of all workflow components. Provides three lifecycle methods:
- `prep(shared)`: Prepare data for execution
- `exec(prepRes)`: Execute the main logic
- `post(shared, prepRes, execRes)`: Post-process and return next action

### Node
Extends BaseNode with retry logic and error handling:
- Configurable retry attempts with wait times
- Custom fallback handling via `execFallback()`

### Flow
Orchestrates node execution:
- Manages workflow state and transitions
- Handles conditional branching based on node results
- Supports parameter passing between nodes

### Chaining Operators
- `>>`: Chain nodes with default transition
- `-`: Create conditional transitions (e.g., `nodeA - 'success' >> nodeB`)

## Examples

### Conditional Workflow
```dart
final validator = ValidationNode();
final successNode = SuccessNode();
final errorNode = ErrorNode();

// Set up conditional branches
(validator - 'valid') >> successNode;
(validator - 'invalid') >> errorNode;

final flow = Flow();
flow.start(validator);
```

### Batch Processing
```dart
class BatchProcessor extends BatchNode<String> {
  @override
  String? execSingle(dynamic item) {
    return item.toString().toUpperCase();
  }
}

final batchNode = BatchProcessor();
// Processes: ['a', 'b', 'c'] -> ['A', 'B', 'C']
```

### Async Workflows
```dart
class AsyncProcessor extends AsyncNode<String> {
  @override
  Future<String?> execAsync(dynamic prepRes) async {
    await Future.delayed(Duration(seconds: 1));
    return 'Processed: $prepRes';
  }
}

final asyncFlow = AsyncFlow();
asyncFlow.start(AsyncProcessor());
await asyncFlow.runAsync(shared);
```

---

## Development 🛠️

This project follows Test-Last Development (TLD) principles and uses [Very Good Analysis][very_good_analysis_link] for code quality.

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.15.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
