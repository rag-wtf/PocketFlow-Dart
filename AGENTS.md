# Agent Instructions for PocketFlow-Dart

This guide is for AI agents contributing to this project. Follow these instructions to ensure your contributions are aligned with the project's standards.

## 1. Project Overview

The goal of this project is to port the core runtime of PocketFlow from Python to a pure Dart library. The core components are `Node`, `BaseNode`, and `Flow`, which allow for creating and executing graph-based workflows.

## 2. Core Principles

- **Test-Driven Development (TDD)**: Tests MUST be written before the implementation. All new code must have corresponding tests, and all tests must pass before merging.
- **Simplicity**: The implementation should be simple, clean, and easy to understand. Avoid over-engineering.
- **No Dependencies**: The core library must not have any third-party dependencies from `pub.dev`.
- **Follow the Plan**: Adhere to the tasks and designs laid out in the `specs/` directory.

## 3. Tech Stack

- **Language**: Dart 3.x (with sound null safety)
- **Testing**: `package:test`
- **Linting**: `package:very_good_analysis` (using Very Good Analysis rules)

## 4. Project Structure

```
.
├── lib/
│   ├── pocketflow.dart      # Public API export file
│   └── src/                 # Core implementation files
│       ├── base_node.dart
│       ├── node.dart
│       └── flow.dart
├── test/
│   └── src/                 # Test files mirroring `lib/src`
│       ├── base_node_test.dart
│       ├── node_test.dart
│       └── flow_test.dart
├── specs/                   # Specifications, plans, tasks and issues
└── AGENTS.md                # This file
```

## 5. Development Workflow

Follow the tasks outlined in `specs/issues` in the specified order.

1.  **Setup**: Execute the `source setup.sh` command to setup the Dart environment.
2.  **Create files/directories**: Create the necessary files and directories.
3.  **Write Tests**: Write failing tests for the feature you are implementing.
4.  **Implement**: Write the code to make the tests pass.
5.  **Polish**: Add documentation, format, and lint the code.
6.  **Submit Changes**: Submit the changes according to format of the `.github/PULL_REQUEST_TEMPLATE.md` file.

## 6. Key Commands

- **Run tests**: `dart test`
- **Lint and analyze**: `dart analyze`
- **Fix lint and analysis errors**: `dart fix --apply`
- **Format code**: `dart format --line-length 80 lib test`

## 7. Dos and Don'ts

- **DO** follow the TDD process strictly.
- **DO** write clear and descriptive commit messages.
- **DO** ensure `dart analyze` and `dart test` pass before submitting changes.
- **DON'T** add any third-party dependencies to `pubspec.yaml`.
- **DON'T** implement functionality that is not specified in a task.
- **DON'T** modify files outside the scope of your assigned task unless approved by the user.
