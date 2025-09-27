
# Implementation Plan: PocketFlow Dart Port

**Branch**: `010-analysis` | **Date**: 2025-09-27 | **Spec**: [./spec.md](./spec.md)
**Input**: Feature specification from `/home/limcheekin/dev/ws/rag.wtf/PocketFlow-Dart/specs/010-analysis/spec.md`

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

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
The Dart implementation of PocketFlow is an incomplete and partially incorrect port of the Python version. This plan outlines the work required to bring the Dart implementation to parity with the Python version, addressing missing classes, incorrect logic, and missing features.

## Technical Context
**Language/Version**: Dart ^3.9.0
**Primary Dependencies**: `mocktail`, `test`, `very_good_analysis`
**Storage**: N/A
**Testing**: `test` package
**Target Platform**: Dart VM
**Project Type**: single project
**Performance Goals**: Comparable performance to the Python implementation.
**Constraints**: None
**Scale/Scope**: Porting features from Python implementation to achieve parity.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

*   **Principle 1: Test-Driven Development**: All new features must be accompanied by tests.
*   **Principle 2: Clear Documentation**: All public APIs must be documented.
*   **Principle 3: Parity with Python**: The Dart implementation should aim for functional and API parity with the Python implementation.

**Violations**:
*   The existing `Flow` implementation is incorrect and not tested.
*   Missing classes are not implemented and therefore not tested.

## Project Structure

### Documentation (this feature)
```
specs/010-analysis/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── test/                # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
lib/
└── src/
    ├── base_node.dart
    ├── node.dart
    ├── flow.dart
    # ... new classes to be added here
tests/
└── src/
    ├── base_node_test.dart
    ├── node_test.dart
    ├── flow_test.dart
    # ... new tests to be added here
```

**Structure Decision**: The project is a single library, so the existing structure will be maintained and extended.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - Research Dart's `async` features for `Async*` classes.
   - Investigate cloning/copying mechanisms in Dart for state isolation.
   - Research operator overloading in Dart.
   - Define a benchmarking strategy.

2. **Generate and dispatch research agents**:
   - The research has been completed and the findings are consolidated in `research.md`.

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: `research.md` with all NEEDS CLARIFICATION resolved.

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - The data model has been documented in `data-model.md`.

2. **Generate API contracts** from functional requirements:
   - Create contract tests for the public methods of all classes.

3. **Generate contract tests** from contracts:
   - One test file per class.
   - Assert request/response schemas.
   - Tests must fail (no implementation yet).

4. **Extract test scenarios** from user stories:
   - Create integration tests that replicate the behavior of the Python implementation.

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh gemini`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, test/*, failing tests, quickstart.md, agent-specific file.

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate setup tasks for project initialization and linting.
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each class → implementation task [P]
- Each class → test task [P]
- Integration tests for flows.

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Base classes before specialized classes.

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Incorrect `Flow` implementation | Needs to be fixed to match Python version | N/A |
| Missing classes | Required for feature parity | N/A |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
