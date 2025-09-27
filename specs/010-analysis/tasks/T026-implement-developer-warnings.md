---
name: Feature Request
about: A new feature to be added to the project
title: "feat: Implement developer warnings"
labels: feature
---

**Description**

Implement developer warnings in `lib/src/base_node.dart` and `lib/src/flow.dart`. These warnings will help developers avoid common mistakes.

**Requirements**

- [ ] Implement a warning when a node's successor is overwritten.
- [ ] Implement a warning when `run()` is called on a node with successors outside of a `Flow`.
