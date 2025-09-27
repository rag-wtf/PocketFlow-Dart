---
name: Feature Request
about: A new feature to be added to the project
title: "feat: Implement clone() method in BaseNode"
labels: feature
---

**Description**

Implement the `clone()` method in `lib/src/base_node.dart`. This method is crucial for isolating the execution state of nodes within a `Flow`, preventing a run from affecting the state of the original node instances in the flow graph.

**Requirements**

- [ ] Implement the `clone()` method in `lib/src/base_node.dart`.
- [ ] The method should return a new instance of the `BaseNode` with the same properties as the original.
