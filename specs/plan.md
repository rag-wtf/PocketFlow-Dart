# Implementation Plan: Port PocketFlow's Core Runtime to Dart

**Branch**: `001-port-pocketflow-s` | **Date**: 2025-09-26 | **Spec**: [./spec.md](./spec.md)
**Input**: Feature specification from `/home/limcheekin/dev/ws/rag.wtf/PocketFlow-Dart/specs/001-port-pocketflow-s/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

## Summary
This plan outlines the porting of the PocketFlow core runtime from Python to a Dart library. The core entities are `Node`, `Graph`, and `Flow`. The implementation will follow the technical context below, resulting in a well-tested, dependency-free Dart package.

## Technical Context
**Language/Version**: Dart 3.x
**Primary Dependencies**: None
**Storage**: N/A
**Testing**: `package:test`
**Target Platform**: All platforms supported by Dart.
**Project Type**: single
**Performance Goals**: N/A for initial port.
**Constraints**: No binary or native dependencies.
**Scale/Scope**: Core runtime (Graph/Node/Flow).

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- All principles passed (constitution is a template).

## Project Structure

### Documentation (this feature)
```
specs/001-port-pocketflow-s/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── base_node.md
│   ├── node.md
│   └── flow.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
lib/
├── pocketflow.dart      # Public API export file
└── src/
    ├── base_node.dart
    ├── node.dart
    └── flow.dart

test/
└── src/
    ├── base_node_test.dart
    ├── node_test.dart
    └── flow_test.dart
```

**Structure Decision**: The project is a single Dart library. The source code will be placed in `lib/src/`, with the public API exposed through `lib/pocketflow.dart`. Tests will mirror the source structure in the `test/` directory.

## Phase 0: Outline & Research
Completed. See `research.md`.

## Phase 1: Design & Contracts
Completed. See `data-model.md`, `contracts/`, and `quickstart.md`.

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from the created design documents (`data-model.md`, `contracts/`, `quickstart.md`).
- For each class in the contracts, create a task to implement it and a corresponding test file.
- Create tasks to port the unit tests from the Python implementation.

**Ordering Strategy**:
- TDD order: Tests before implementation.
- Dependency order: `BaseNode` -> `Node` -> `Flow`.
- Mark tasks for parallel execution where possible.

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
No violations.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*