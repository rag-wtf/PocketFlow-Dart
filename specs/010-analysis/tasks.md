# Tasks: PocketFlow Dart Port

**Input**: Design documents from `/home/limcheekin/dev/ws/rag.wtf/PocketFlow-Dart/specs/010-analysis/`
**Prerequisites**: plan.md, research.md, data-model.md, quickstart.md

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- Paths shown below assume single project structure.

## Phase 3.1: Setup
- [ ] T001 Verify linting and formatting tools are configured in `pubspec.yaml` and `analysis_options.yaml`.

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T002 [P] Create failing test for `BaseNode.clone()` in `test/src/base_node_test.dart`.
- [ ] T003 [P] Create failing test for `Flow` state isolation (using `clone()`) in `test/src/flow_test.dart`.
- [ ] T004 [P] Create failing test for `Flow` parameter passing in `test/src/flow_test.dart`.
- [ ] T005 [P] Create failing tests for `BatchNode` in `test/src/batch_node_test.dart`.
- [ ] T006 [P] Create failing tests for `BatchFlow` in `test/src/batch_flow_test.dart`.
- [ ] T007 [P] Create failing tests for `AsyncNode` in `test/src/async_node_test.dart`.
- [ ] T008 [P] Create failing tests for `AsyncFlow` in `test/src/async_flow_test.dart`.
- [ ] T009 [P] Create failing tests for `AsyncBatchNode` in `test/src/async_batch_node_test.dart`.
- [ ] T010 [P] Create failing tests for `AsyncParallelBatchNode` in `test/src/async_parallel_batch_node_test.dart`.
- [ ] T011 [P] Create failing tests for `AsyncBatchFlow` in `test/src/async_batch_flow_test.dart`.
- [ ] T012 [P] Create failing tests for `AsyncParallelBatchFlow` in `test/src/async_parallel_batch_flow_test.dart`.
- [ ] T013 [P] Create failing test for operator overloading (`>>` and `-`) in `test/pocketflow_test.dart`.

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T014 Implement `clone()` method in `lib/src/base_node.dart`.
- [ ] T015 Implement `clone()` method in `lib/src/node.dart` and `lib/src/flow.dart`.
- [ ] T016 Correct `Flow.run()` logic for state isolation and parameter passing in `lib/src/flow.dart`.
- [ ] T017 [P] Implement `BatchNode` in `lib/src/batch_node.dart`.
- [ ] T018 [P] Implement `BatchFlow` in `lib/src/batch_flow.dart`.
- [ ] T019 [P] Implement `AsyncNode` in `lib/src/async_node.dart`.
- [ ] T020 [P] Implement `AsyncFlow` in `lib/src/async_flow.dart`.
- [ ] T021 [P] Implement `AsyncBatchNode` in `lib/src/async_batch_node.dart`.
- [ ] T022 [P] Implement `AsyncParallelBatchNode` in `lib/src/async_parallel_batch_node.dart`.
- [ ] T023 [P] Implement `AsyncBatchFlow` in `lib/src/async_batch_flow.dart`.
- [ ] T024 [P] Implement `AsyncParallelBatchFlow` in `lib/src/async_parallel_batch_flow.dart`.
- [ ] T025 Implement operator overloading (`>>` and `-`) in `lib/src/base_node.dart`.
- [ ] T026 Implement developer warnings in `lib/src/base_node.dart` and `lib/src/flow.dart`.

## Phase 3.4: Polish
- [ ] T027 [P] Add documentation for all public APIs in `lib/`.
- [ ] T028 [P] Create benchmark tests in `test/benchmark/`.

## Dependencies
- T002 blocks T014.
- T003, T004 block T016.
- T005 blocks T017.
- T006 blocks T018.
- T007 blocks T019.
- T008 blocks T020.
- T009 blocks T021.
- T010 blocks T022.
- T011 blocks T023.
- T012 blocks T024.
- T013 blocks T025.

## Parallel Example
```
# Launch T005-T013 together:
Task: "Create failing tests for BatchNode in test/src/batch_node_test.dart"
Task: "Create failing tests for BatchFlow in test/src/batch_flow_test.dart"
# ... and so on for all the new classes and features.
```
