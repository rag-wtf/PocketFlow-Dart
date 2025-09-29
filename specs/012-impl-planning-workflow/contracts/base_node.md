# `BaseNode` Contract

## Public API

### Properties

- `params`: `Map<String, dynamic>`
- `name`: `String`
- `successors`: `Map<String, BaseNode>`

### Methods

- `prep(Map<String, dynamic> shared)`: `dynamic`
- `exec(dynamic prepResult)`: `dynamic`
- `post(Map<String, dynamic> shared, dynamic prepResult, dynamic execResult)`: `dynamic`
- `clone()`: `BaseNode`
