# Contribution Guide

Welcome to the PocketFlow-Dart project! We're excited to have you as a potential contributor. This guide will help you get started and make meaningful contributions to our pure Dart library for graph-based workflows.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Licensing](#licensing)
3. [Code of Conduct](#code-of-conduct)
4. [Getting Started](#getting-started)
5. [Contributor Guidelines](#contributor-guidelines)
6. [Coding Standards](#coding-standards)
7. [Issue and Pull Request Management](#issue-and-pull-request-management)
8. [Testing and Quality Assurance](#testing-and-quality-assurance)
9. [Documentation](#documentation)
10. [Community Guidelines](#community-guidelines)
11. [Recognizing Contributions](#recognizing-contributions)
12. [Updating the Guide](#updating-the-guide)
13. [Feedback and Support](#feedback-and-support)

### Project Overview

PocketFlow-Dart is a pure Dart port of the PocketFlow core runtime, enabling graph-based workflow execution in Dart. The project is hosted at [https://github.com/rag-wtf/PocketFlow-Dart](https://github.com/rag-wtf/PocketFlow-Dart). We value contributions that enhance the project's functionality, maintain its quality, and keep the codebase simple and dependency-free.

### Licensing

This project is licensed under the [MIT License](LICENSE). By contributing, you agree to license your contributions under the same terms.

### Code of Conduct

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing. We prioritize a welcoming and inclusive community.

### Getting Started

1. Fork and clone the repository: https://github.com/rag-wtf/PocketFlow-Dart/fork
2. Install dependencies: `dart pub get`
3. Set up your development environment:
   - Ensure you have Dart 3.x installed. See [Dart installation guide](https://dart.dev/get-dart).

### Contributor Guidelines

We welcome contributions of all kinds, including code, documentation, and tests. To contribute:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/your-feature-name` (or use another appropriate prefix: fix, test, docs, etc.)
3. Write tests for your feature or fix before implementing it (TDD is required).
4. Implement your changes.
5. Ensure all tests pass and code is formatted and linted.
6. Submit a pull request.

### Coding Standards

The project uses the [very_good_analysis](https://pub.dev/packages/very_good_analysis) package for linting. Before committing any changes, ensure:

- Run `dart analyze` and resolve all issues.
- Run `dart format --line-length 80 lib test` to format code.
- Run `dart fix --apply` to auto-fix lint issues.

### Issue and Pull Request Management

- [Create an Issue](https://github.com/rag-wtf/PocketFlow-Dart/issues/new) for bug reports, feature requests, or discussions.
- When creating a pull request, ensure it is clear, addresses an existing issue, and follows the template.
- If you are new to using Pull Requests, you can learn how with this _free_ series: [How to Contribute to an Open Source Project on GitHub](https://kcd.im/pull-request)

### Testing and Quality Assurance

We maintain a rigorous testing process. **All new contributions must be covered by unit tests to ensure that test coverage remains at 100%.**

Please ensure thorough testing of your changes:

1. Run all tests with:

   ```bash
   dart test
   ```

2. Ensure all tests pass and coverage remains at 100%. You can generate and view a coverage report with:

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

Please verify that you see the message 'All tests passed.' on the console in both steps 1 and 2.

### Documentation

Thorough documentation is essential. Please:

- Add DartDoc comments to all public APIs and new features.
- Update the `README.md` and any relevant documentation if your change affects usage or behavior.

### Community Guidelines

We encourage a positive and collaborative atmosphere. Please be respectful and constructive in your interactions.

### Recognizing Contributions

We acknowledge contributors in our README and release notes. Your contributions are highly valued!

### Updating the Guide

If you find errors or want to improve this guide, feel free to open a pull request.

### Feedback and Support

For questions, feedback, or support, please open an issue on GitHub or contact the maintainers listed in the repository.
