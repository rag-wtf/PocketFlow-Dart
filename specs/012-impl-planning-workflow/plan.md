
# Implementation Plan: Gap Analysis Remediation

**Branch**: `012-impl-planning-workflow` | **Date**: 2025-09-29 | **Spec**: [link](./spec.md)
**Input**: Feature specification from `/specs/012-impl-planning-workflow/spec.md`

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
This plan outlines the necessary steps to remediate the differences between the Dart and Python implementations of PocketFlow, as identified in the gap analysis. The goal is to achieve feature parity by addressing critical issues in async/sync architecture, inheritance patterns, and flow orchestration, while preserving beneficial Dart-specific features.

## Technical Context
**Language/Version**: Dart 3.x
**Primary Dependencies**: test
**Storage**: N/A
**Testing**: test
**Target Platform**: Dart VM
**Project Type**: single
**Performance Goals**: No performance regressions compared to the Python implementation.
**Constraints**: Must be compatible with Dart 3.x and the existing dependencies.
**Scale/Scope**: The scale and scope are defined by the existing test suite.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

*   **Library-First**: The project is a single library, so this principle is met.
*   **CLI Interface**: Not applicable for this library.
*   **Test-First (NON-NEGOTIABLE)**: All changes will be driven by tests.
*   **Integration Testing**: Integration tests will be created to validate the flow orchestration.
*   **Simplicity**: The plan aims to simplify the architecture by aligning it with the Python implementation.

## Project Structure

### Documentation (this feature)
```
specs/012-impl-planning-workflow/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
lib/
└── src/
    ├── async_batch_flow.dart
    ├── async_batch_node.dart
    ├── async_flow.dart
    ├── async_node.dart
    ├── async_parallel_batch_flow.dart
    ├── async_parallel_batch_node.dart
    ├── base_node.dart
    ├── batch_flow.dart
    ├── batch_node.dart
    ├── flow.dart
    ├── iterating_batch_node.dart
    ├── node.dart
    ├── parallel_node_batch_flow.dart
    └── streaming_batch_flow.dart

test/
└── src/
    ├── async_batch_flow_test.dart
    ├── async_batch_node_test.dart
    ├── async_flow_test.dart
    ├── async_node_test.dart
    ├── async_parallel_batch_flow_test.dart
    ├── async_parallel_batch_node_test.dart
    ├── base_node_test.dart
    ├── batch_flow_test.dart
    ├── batch_node_test.dart
    ├── flow_test.dart
    ├── iterating_batch_node_test.dart
    ├── node_test.dart
    ├── parallel_node_batch_flow_test.dart
    └── streaming_batch_flow_test.dart
```

**Structure Decision**: The project is a single Dart library, so the structure will follow the standard Dart package layout.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh gemini`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

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
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


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
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
