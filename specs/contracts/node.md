# Node API Contract

Defines the public interface for a `Node`.

## class Node extends BaseNode

### Constructor
- `Node({int maxRetries = 1, Duration wait = Duration.zero})`

### Methods
- `Future<dynamic> exec(dynamic prepResult)`: The core logic of the node. To be overridden by subclasses.
- `Future<dynamic> execFallback(dynamic prepResult, Exception error)`: Fallback logic if `exec` fails after all retries. The default implementation re-throws the error.
