# BaseNode API Contract

Defines the public interface for a `BaseNode`.

## abstract class BaseNode

### Properties
- `Map<String, dynamic> params`: Parameters for the node.
- `Map<String, BaseNode> successors`: Successor nodes.

### Methods
- `void setParams(Map<String, dynamic> params)`: Sets the parameters for the node.
- `BaseNode next(BaseNode node, {String action = "default"})`: Defines the next node in the sequence.
- `Future<dynamic> prep(Map<String, dynamic> shared)`: Pre-processing logic before `exec`.
- `Future<dynamic> post(Map<String, dynamic> shared, dynamic prepResult, dynamic execResult)`: Post-processing logic after `exec`.
- `Future<dynamic> run(Map<String, dynamic> shared)`: Executes the node's lifecycle (`prep` -> `exec` -> `post`).
