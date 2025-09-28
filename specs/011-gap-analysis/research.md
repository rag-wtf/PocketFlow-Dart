# Research: Python Parity

## Decision

The plan is to enhance the existing Dart library, not replace it. We will retain the superior architectural choices of the Dart port (e.g., deep cloning for state isolation, unified `Future`-based async model) while introducing the Python version's specific behaviors as new, clearly-named classes.

## Rationale

This will make the Dart library a superset of the Python version's capabilities, offering developers more strategic choices for different problems.

## Alternatives Considered

Replacing the Dart implementation with a direct port of the Python version was considered but rejected because the Dart version has superior architectural choices in terms of state isolation and async handling.
