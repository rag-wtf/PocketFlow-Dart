---
name: Test
about: Adding missing tests or correcting existing tests
title: "test: Create failing test for Flow state isolation"
labels: test
---

**Description**

Create a failing test to verify that the `Flow` class properly isolates state between runs. This should be achieved by cloning the nodes in the flow before execution.

**Requirements**

- [ ] Create a new test case in `test/src/flow_test.dart`.
- [ ] The test should modify the state of a node in the flow and verify that the state is not persisted on the next run.
- [ ] The test should fail because the `Flow` class is not yet using `clone()`.
