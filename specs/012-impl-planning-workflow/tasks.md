# Tasks for Gap Analysis Remediation

This document outlines the tasks required to remediate the differences between the Dart and Python implementations of PocketFlow.

## Phase 1: Core Architecture (Critical)

### T001: Test `BaseNode` synchronous lifecycle and cloning [P]
- **File**: `test/src/base_node_test.dart`
- **Details**: Write tests to verify the `prep`, `exec`, and `post` methods are called in the correct order for synchronous nodes. Also, test the `clone` method.

### T002: Implement `BaseNode` synchronous lifecycle and cloning
- **File**: `lib/src/base_node.dart`
- **Details**: Implement the synchronous `_run` method and the `clone` and `_createInstance` methods.

### T003: Test `Node` retry logic [P]
- **File**: `test/src/node_test.dart`
- **Details**: Write tests to verify the retry logic in the `Node` class, including the `maxRetries` and `wait` parameters.

### T004: Implement `Node` retry logic
- **File**: `lib/src/node.dart`
- **Details**: Implement the retry logic in the `_exec` method.

### T005: Test `AsyncNode` inheritance and async lifecycle [P]
- **File**: `test/src/async_node_test.dart`
- **Details**: Write tests to verify that `AsyncNode` uses an inheritance-based model and that the `prepAsync`, `execAsync`, and `postAsync` methods are called correctly.

### T006: Implement `AsyncNode` inheritance and async lifecycle
- **File**: `lib/src/async_node.dart`
- **Details**: Refactor `AsyncNode` to use an inheritance-based model and implement the `_runAsync` method.

## Phase 2: Batch Processing (High)

### T007: Test `BatchNode` concrete implementation [P]
- **File**: `test/src/batch_node_test.dart`
- **Details**: Write tests to verify that `BatchNode` is a concrete class with default batch processing behavior.

### T008: Implement `BatchNode` as a concrete class
- **File**: `lib/src/batch_node.dart`
- **Details**: Make `BatchNode` a concrete class that extends `Node` and provides a default implementation for batch processing.

### T009: Test `AsyncBatchNode` with mixins [P]
- **File**: `test/src/async_batch_node_test.dart`
- **Details**: Write tests to verify the behavior of `AsyncBatchNode`, which should use mixins to achieve multiple inheritance of async and batch behaviors.

### T010: Implement `AsyncBatchNode` with mixins
- **File**: `lib/src/async_batch_node.dart`
- **Details**: Implement `AsyncBatchNode` using `AsyncNode` and `AsyncBatchNodeMixin`.

### T011: Test `AsyncParallelBatchNode` [P]
- **File**: `test/src/async_parallel_batch_node_test.dart`
- **Details**: Write tests to verify that `AsyncParallelBatchNode` processes items in parallel.

### T012: Implement `AsyncParallelBatchNode`
- **File**: `lib/src/async_parallel_batch_node.dart`
- **Details**: Implement `AsyncParallelBatchNode` to process items in parallel using `Future.wait`.

## Phase 3: Flow Orchestration (High)

### T013: Test `Flow` orchestration [P]
- **File**: `test/src/flow_test.dart`
- **Details**: Write tests to verify that the `Flow` class orchestrates nodes based on actions and that the `_orch` method matches the Python implementation.

### T014: Implement `Flow` orchestration
- **File**: `lib/src/flow.dart`
- **Details**: Implement the `_orch` and `getNextNode` methods in the `Flow` class.

### T015: Test `BatchFlow` orchestration [P]
- **File**: `test/src/batch_flow_test.dart`
- **Details**: Write tests to verify the orchestration logic of `BatchFlow`.

### T016: Implement `BatchFlow` orchestration
- **File**: `lib/src/batch_flow.dart`
- **Details**: Implement the `_run` method in `BatchFlow` to handle batch parameters.

## Phase 4: Extensions (Low)

### T017: Refactor Dart-specific classes into an extension file [P]
- **Files**: `lib/src/iterating_batch_node.dart`, `lib/src/parallel_node_batch_flow.dart`, `lib/src/streaming_batch_flow.dart`
- **Details**: Move `IteratingBatchNode`, `ParallelNodeBatchFlow`, and `StreamingBatchFlow` to a separate `lib/pocketflow_extensions.dart` file.

### T018: Update documentation and examples
- **Files**: `README.md`, `specs/012-impl-planning-workflow/quickstart.md`
- **Details**: Update the documentation and examples to reflect the refactored library.

## Parallel Execution

The following tasks can be run in parallel:
- `T001`, `T003`, `T005`, `T007`, `T009`, `T011`, `T013`, `T015`, `T017`
