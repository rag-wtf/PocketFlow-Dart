# Data Model

This document outlines the data models for the PocketFlow library, based on the gap analysis and remediation plan.

## Core Classes

### `BaseNode`

**Description**: The fundamental building block of a workflow. It defines the synchronous lifecycle methods.

**Fields**:
- `params`: `Map<String, dynamic>`
- `name`: `String`
- `successors`: `Map<String, BaseNode>`

**Methods**:
- `prep(Map<String, dynamic> shared)`: `dynamic`
- `exec(dynamic prepResult)`: `dynamic`
- `post(Map<String, dynamic> shared, dynamic prepResult, dynamic execResult)`: `dynamic`
- `_run(Map<String, dynamic> shared)`: `dynamic`
- `clone()`: `BaseNode`
- `_createInstance()`: `BaseNode`

### `Node`

**Description**: Extends `BaseNode` with retry logic.

**Fields**:
- `maxRetries`: `int`
- `wait`: `Duration`

**Methods**:
- `execFallback(dynamic prepResult, Exception e)`: `dynamic`

### `AsyncNode`

**Description**: Extends `Node` to support asynchronous operations.

**Methods**:
- `prepAsync(Map<String, dynamic> shared)`: `Future<dynamic>`
- `execAsync(dynamic prepResult)`: `Future<dynamic>`
- `postAsync(Map<String, dynamic> shared, dynamic prepResult, dynamic execResult)`: `Future<dynamic>`
- `_runAsync(Map<String, dynamic> shared)`: `Future<dynamic>`

### `BatchNode`

**Description**: A concrete `Node` that processes a list of items.

**Generics**:
- `I`: Input item type
- `O`: Output item type

### `AsyncBatchNode`

**Description**: An `AsyncNode` that processes a list of items asynchronously.

**Generics**:
- `I`: Input item type
- `O`: Output item type

### `AsyncParallelBatchNode`

**Description**: An `AsyncNode` that processes a list of items in parallel.

**Generics**:
- `I`: Input item type
- `O`: Output item type

### `Flow`

**Description**: Orchestrates a workflow of `BaseNode`s.

**Fields**:
- `startNode`: `BaseNode`

**Methods**:
- `_orch(Map<String, dynamic> shared, [Map<String, dynamic>? params])`: `dynamic`
- `getNextNode(BaseNode curr, dynamic action)`: `BaseNode?`

### `BatchFlow`

**Description**: A `Flow` that processes a batch of inputs.

