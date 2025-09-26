# Tasks: Port PocketFlow's Core Runtime to Dart

**Input**: Design documents from `/home/limcheekin/dev/ws/rag.wtf/PocketFlow-Dart/specs/001-port-pocketflow-s/`

## Phase 3.1: Setup
- [ ] T001 [P] Create the directory structure in `lib/` and `test/` as defined in the implementation plan.
- [ ] T002 [P] Create empty files: `lib/pocketflow.dart`, `lib/src/base_node.dart`, `lib/src/node.dart`, `lib/src/flow.dart`.
- [ ] T003 [P] Create empty test files: `test/src/base_node_test.dart`, `test/src/node_test.dart`, `test/src/flow_test.dart`.

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
- [ ] T004 [P] Write tests for `BaseNode` in `test/src/base_node_test.dart`. Port logic from `third_party/PocketFlow-Python/tests/test_flow_basic.py`.
- [ ] T005 [P] Write tests for `Node` in `test/src/node_test.dart`. Port logic from `third_party/PocketFlow-Python/tests/test_flow_basic.py` and `test_async_flow.py`.
- [ ] T006 [P] Write tests for `Flow` in `test/src/flow_test.dart`. Port logic from `third_party/PocketFlow-Python/tests/test_flow_basic.py`.

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T007 Implement the `BaseNode` class in `lib/src/base_node.dart` based on the `contracts/base_node.md` file.
- [ ] T008 Implement the `Node` class in `lib/src/node.dart` based on the `contracts/node.md` file. This depends on T007.
- [ ] T009 Implement the `Flow` class in `lib/src/flow.dart` based on the `contracts/flow.md` file. This depends on T007.
- [ ] T010 Export the classes in `lib/pocketflow.dart`.

## Phase 3.4: Polish
- [ ] T011 [P] Add doc comments to all public APIs in `lib/src/`.
- [ ] T012 Run `dart format .` to ensure all code is formatted.
- [ ] T013 Run `dart analyze` to ensure there are no analysis errors.
- [ ] T014 Run `dart test` and ensure all tests pass.

## Dependencies
- Setup (T001-T003) must be done first.
- Tests (T004-T006) must be written before implementation (T007-T010).
- T007 (BaseNode implementation) must be done before T008 (Node) and T009 (Flow).
- Core implementation (T007-T010) must be done before polish (T011-T014).

## Parallel Example
```
# The setup and test creation tasks can be run in parallel:
Task: "T001 [P] Create the directory structure in lib/ and test/ as defined in the implementation plan."
Task: "T002 [P] Create empty files: lib/pocketflow.dart, lib/src/base_node.dart, lib/src/node.dart, lib/src/flow.dart."
Task: "T003 [P] Create empty test files: test/src/base_node_test.dart, test/src/node_test.dart, test/src/flow_test.dart."
Task: "T004 [P] Write tests for BaseNode in test/src/base_node_test.dart..."
Task: "T005 [P] Write tests for Node in test/src/node_test.dart..."
Task: "T006 [P] Write tests for Flow in test/src/flow_test.dart..."
```
