---
name: Test
about: Adding missing tests or correcting existing tests
title: "test: Create failing test for operator overloading"
labels: test
---

**Description**

Create a failing test for operator overloading (`>>` and `-`). This test should verify that the operators can be used to define flows in a more fluent way.

**Requirements**

- [ ] Create a new test case in `test/pocketflow_test.dart`.
- [ ] The test should define a flow using the `>>` and `-` operators.
- [ ] The test should fail because the operators are not implemented yet.
