# Data Model

This document is based on the Key Entities section of the feature specification and the Python implementation.

## Entities

### Node
Represents a single, atomic unit of work in a workflow.

**Fields**:
- `params`: `Map<String, dynamic>` - Parameters specific to this node instance.
- `successors`: `Map<String, Node>` - A map of action names to the next `Node` to be executed.
- `maxRetries`: `int` - The maximum number of times to retry the node on failure.
- `wait`: `Duration` - The duration to wait between retries.

**State Transitions**:
- A `Node` is stateless from the perspective of the `Flow`. Its execution is a single event. It can have internal state during its `exec` method, but this is not managed by the `Flow`.

### Graph
Represents the entire workflow structure as a collection of connected nodes. While not an explicit class in the Python implementation, it's a key concept. In Dart, this might be represented by the `Flow` class itself or a dedicated `Graph` class.

**Fields**:
- `startNode`: `Node` - The entry point of the graph.

**Validation Rules**:
- The graph MUST be a Directed Acyclic Graph (DAG). Circular dependencies are not allowed and must be detected.

### Flow
Represents an executable instance of a `Graph`. It manages the traversal of the graph and the execution of nodes.

**Fields**:
- `startNode`: `Node` - The starting node of the flow.

**State Transitions**:
- `running` -> `completed`
- `running` -> `failed`

