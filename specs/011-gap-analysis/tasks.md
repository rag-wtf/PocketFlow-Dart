# Tasks: Python Parity

**Input**: Design documents from `/specs/011-gap-analysis/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `lib/` and `test/` at repository root

## Phase 3.1: Renaming and Deprecation
- [ ] T001 [P] Create failing test for renaming `AsyncBatchFlow` by renaming `test/src/async_batch_flow_test.dart` to `test/src/streaming_batch_flow_test.dart` and updating test descriptions.
- [ ] T002 Rename `AsyncBatchFlow` to `StreamingBatchFlow`, rename the file `lib/src/async_batch_flow.dart` to `lib/src/streaming_batch_flow.dart`, and update all references.
- [ ] T003 [P] Create failing test for renaming `AsyncParallelBatchFlow` by renaming `test/src/async_parallel_batch_flow_test.dart` to `test/src/parallel_node_batch_flow_test.dart` and updating test descriptions.
- [ ] T004 Rename `AsyncParallelBatchFlow` to `ParallelNodeBatchFlow`, rename the file `lib/src/async_parallel_batch_flow.dart` to `lib/src/parallel_node_batch_flow.dart`, and update all references.

## Phase 3.2: New Feature Implementation (TDD)
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T005 [P] Create a new test file `test/src/async_batch_flow_test.dart` and add a failing test for the new `AsyncBatchFlow` class.
- [ ] T006 Create a new file `lib/src/async_batch_flow.dart` and implement the new `AsyncBatchFlow` class.
- [ ] T007 [P] Create a new test file `test/src/async_parallel_batch_flow_test.dart` and add a failing test for the new `AsyncParallelBatchFlow` class.
- [ ] T008 Create a new file `lib/src/async_parallel_batch_flow.dart` and implement the new `AsyncParallelBatchFlow` class.
- [ ] T009 [P] Create a new test file `test/src/iterating_batch_node_test.dart` and add a failing test for the new `IteratingBatchNode` class.
- [ ] T010 Create a new file `lib/src/iterating_batch_node.dart` and implement the new `IteratingBatchNode` class.

## Phase 3.3: Polish
- [ ] T011 [P] Update documentation for all new and renamed classes.
- [ ] T012 [P] Run all tests and ensure they pass.

## Dependencies
- T001 blocks T002
- T003 blocks T004
- T005 blocks T006
- T007 blocks T008
- T009 blocks T010

## Parallel Example
```
# Launch T001, T003, T005, T007, T009 together:
Task: "Create failing test for renaming `AsyncBatchFlow` in `test/src/async_batch_flow_test.dart`"
Task: "Create failing test for renaming `AsyncParallelBatchFlow` in `test/src/async_parallel_batch_flow_test.dart`"
Task: "Create failing test for new `AsyncBatchFlow` in `test/src/async_batch_flow_test.dart`"
Task: "Create failing test for new `AsyncParallelBatchFlow` in `test/src/async_parallel_batch_flow_test.dart`"
Task: "Create failing test for new `IteratingBatchNode` in `test/src/iterating_batch_node_test.dart`"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task
