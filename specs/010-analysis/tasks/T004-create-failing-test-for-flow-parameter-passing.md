---
name: Test
about: Adding missing tests or correcting existing tests
title: "test: Create failing test for Flow parameter passing"
labels: test
---

**Description**

Create a failing test to verify that the `Flow` class can pass node-specific parameters down to the nodes during orchestration.

**Requirements**

- [ ] Create a new test case in `test/src/flow_test.dart`.
- [ ] The test should define a flow with a node that expects a specific parameter.
- [ ] The test should run the flow with the parameter and verify that the node receives it.
- [ ] The test should fail because the `Flow` class does not yet implement parameter passing.
