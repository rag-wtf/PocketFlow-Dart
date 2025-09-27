---
name: Refactor
about: A code change that neither fixes a bug nor adds a feature
title: "refactor: Correct Flow.run() logic"
labels: refactor
---

**Description**

Correct the `Flow.run()` logic in `lib/src/flow.dart` to properly handle state isolation and parameter passing. The current implementation uses the original node instances directly, which can cause unintended side effects. It also lacks a mechanism for passing node-specific parameters.

**Requirements**

- [ ] The `run` method should use the `clone()` method to create a new instance of each node before execution.
- [ ] The `run` method should accept a map of parameters and set them on each node before execution.
- [ ] There is no drop in test coverage.
