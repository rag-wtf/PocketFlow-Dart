# Flow API Contract

Defines the public interface for a `Flow`.

## class Flow extends BaseNode

### Constructor
- `Flow({Node? start})`

### Methods
- `Node start(Node start)`: Sets the starting node of the flow.
- `Future<dynamic> run(Map<String, dynamic> shared)`: Runs the entire flow from the start node.
