# PocketFlow Data Model

This document defines the data model for the PocketFlow library, based on the Python implementation.

## Classes

### `BaseNode`

*   **Description**: The abstract base class for all nodes in a flow.
*   **Fields**:
    *   `name`: The name of the node.
    *   `params`: A map of parameters for the node.
    *   `shared`: A map of shared data for the flow.
    *   `successors`: A map of successor nodes.
*   **Methods**:
    *   `run()`: Executes the node's logic.
    *   `next()`: Defines the next node in the flow.
    *   `set_params()`: Sets the parameters for the node.
    *   `clone()`: Creates a copy of the node.

### `Node`

*   **Description**: A concrete implementation of `BaseNode` that executes a synchronous function.
*   **Inherits from**: `BaseNode`
*   **Fields**:
    *   `retries`: The number of times to retry the node on failure.
*   **Methods**:
    *   `_run()`: The internal implementation of the node's logic.

### `Flow`

*   **Description**: A composite node that orchestrates a flow of other nodes.
*   **Inherits from**: `BaseNode`
*   **Fields**:
    *   `_start`: The starting node of the flow.
*   **Methods**:
    *   `run()`: Executes the flow.

### `BatchNode`

*   **Description**: A node that processes a batch of items.
*   **Inherits from**: `Node`

### `BatchFlow`

*   **Description**: A flow that runs over a batch of inputs.
*   **Inherits from**: `Flow`

### `AsyncNode`

*   **Description**: A node that executes an asynchronous function.
*   **Inherits from**: `Node`

### `AsyncFlow`

*   **Description**: A flow that orchestrates asynchronous nodes.
*   **Inherits from**: `Flow`

### `AsyncBatchNode`

*   **Description**: A node for asynchronous batch processing.
*   **Inherits from**: `AsyncNode`

### `AsyncParallelBatchNode`

*   **Description**: A node for parallel, asynchronous batch processing.
*   **Inherits from**: `AsyncNode`

### `AsyncBatchFlow`

*   **Description**: A flow for orchestrating asynchronous batch flows.
*   **Inherits from**: `AsyncFlow`

### `AsyncParallelBatchFlow`

*   **Description**: A flow for orchestrating parallel, asynchronous batch flows.
*   **Inherits from**: `AsyncFlow`

## Relationships

*   A `Flow` is a `BaseNode`.
*   A `Node` is a `BaseNode`.
*   A `Flow` contains a sequence of `BaseNode`s.
*   The other classes are specialized versions of `Node` and `Flow` for batch and asynchronous processing.
