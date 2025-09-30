# Updated implementation plan — **strict Python parity** + full test suite (including missing tests)

Nice — you want the whole enchilada: code changes, test files (including loop guard, concurrency race, async retry/fallback, params precedence), CI hints, and a clear priority list. I gave you a solid plan earlier; this one is *complete* and explicit: exact code edits to make, why they matter, and **all** test files ready to paste into your repo. No hand-waving.

I’ll be blunt: this is a lot of moving parts. Do it in the order below and you’ll avoid 2AM firefights.

---

# TL;DR (one-sentence)

Make these three behavior changes for parity, add the tests below, run them, iterate:

1. Make `BatchFlow.run` return `post(shared, prepResult, null)` (no per-item exec-result collection).
2. Make `Flow.orch` use **shallow copy-on-demand** and add a `maxSteps` guard.
3. Make `AsyncParallelBatchFlow` **copy `shared` per parallel task by default** (safe default), and add `copySharedForParallel` flag.

Then run the test suite below (12 test files). Fix whatever fails until all tests pass.

---

# Assumptions (decision points)

* **Goal:** strict behavioral parity with Python `pocketflow` unless explicitly documented.
* Cloning semantics: **shallow copy per visit** (Python uses `copy.copy`).
* Batch inputs precedence: `params['items']` (batch param) first, fallback to `shared['items']`.
* BatchFlow's `post` receives `exec_result = null` for parity.

If any of the assumptions are wrong, update the plan accordingly — but the tests below assume these choices.

---

# Branching / workflow

1. Create branch: `parity/tests-and-fixes`.
2. Implement changes and tests locally.
3. Run tests (`dart pub get` then `dart test`).
4. Iterate until green.
5. Open PR with checklist below.

---

# Concrete code changes (exact snippets to apply)

## 1) `BatchFlow.run` — replace with Python-parity implementation

**File:** `lib/src/batch_flow.dart` (or wherever your BatchFlow lives)

Replace the current `run` (or `call`) implementation with:

```dart
// -- PATCH START --
@override
Future<dynamic> run(Map<String, dynamic> shared) async {
  // prep should return List<Map<String, dynamic>> (batch param maps)
  final prepResult = await prep(shared) ?? <Map<String, dynamic>>[];

  for (final batchParams in prepResult) {
    final mergedParams = <String, dynamic>{};
    if (params != null) mergedParams.addAll(params);
    mergedParams.addAll(batchParams);
    // orch should accept params override for this batch item
    await orch(shared, mergedParams);
  }

  // Python BatchFlow._run returns post(shared, prep_res, None)
  return post(shared, prepResult, null);
}
// -- PATCH END --
```

**Why:** Python does not aggregate per-item exec results; it calls `post` with `exec_res = None`. This matches parity.

---

## 2) `Flow.orch` (and `Flow` cloning behavior) — shallow copy-on-demand + maxSteps guard

**File:** `lib/src/flow.dart` (or equivalent)

Change orchestration behavior to:

* Clone the *current* node shallowly before executing it (i.e., a `clone()` that **does not clone successors**).
* When moving to `next`, clone that `next` node shallowly.
* Add an optional `maxSteps` guard parameter to `orch` (default to `null` meaning unlimited). Throw error on exceed.

**Suggested implementation sketch (insert/replace the core while loop with the following):**

```dart
// signature: Future<dynamic> orch(Map<String, dynamic> shared, [Map<String, dynamic>? params, int? maxSteps])
var currNode = start!.clone(); // shallow clone
int steps = 0;
dynamic lastAction;
while (currNode != null) {
  if (maxSteps != null && steps >= maxSteps) {
    throw StateError('Flow exceeded maxSteps of $maxSteps — possible infinite loop');
  }
  steps += 1;

  // set node params from merged params (params arg overrides flow.params if provided)
  currNode.params = params ?? this.params ?? {};

  // run node (works for sync or async node if run returns Future)
  lastAction = await currNode.run(shared);

  final nextNodeOriginal = _getNext(currNode, lastAction);
  // shallow clone next node for the next iteration
  currNode = nextNodeOriginal?.clone();
}
return lastAction;
```

**Notes:**

* Ensure `BaseNode.clone()` performs a *shallow* clone that copies node metadata (name, params) but **does not copy successors**.
* This preserves Python’s `copy.copy` semantics (per-visit shallow copy).

---

## 3) `AsyncParallelBatchFlow` — copy `shared` per parallel task (safe default)

**File:** `lib/src/async_parallel_batch_flow.dart` (or similar)

Add a constructor flag `copySharedForParallel` default `true`. Inside your `run`/`call` method where you create futures for each batch item, do:

```dart
final futures = items.map((bp) {
  final mergedParams = {...params, ...bp};
  final sharedForTask = copySharedForParallel ? Map<String, dynamic>.from(shared) : shared;
  return orch(sharedForTask, mergedParams);
}).toList();
final results = await Future.wait(futures);
return post(shared, results, null); // or match BatchFlow semantics if desired
```

**Why:** parallel tasks modifying `shared` concurrently causes race conditions; copying per-task is safer and matches Python's sequential semantics (for parity we should ensure `post` gets `null` exec_result — decide accordingly).

---

## 4) Small API/utility changes

* Add `Flow.orch(..., {int? maxSteps})` overload or optional param.
* Ensure `Node.clone()` is implemented across Node subclasses (BaseNode.clone returning same type shallow copy).
* Document `__node_params__` feature: keep it as an *opt-in* behavior (or disable by default to preserve parity). If you keep it, flag must be explicit (e.g., `applyNodeParams: true`).

---

# Tests suite (12 test files) — full content ready to paste

Create `test/` directory. Below are the tests; they assume your public API exposes `Flow`, `BatchFlow`, `AsyncFlow`, `AsyncParallelBatchFlow`, `Node`, `AsyncNode`, etc. Adjust imports if package name differs.

> Note: tests use simple node classes defined inside test files for clarity. If your `Node` requires different overrides, adapt accordingly.

---

## 1) `test/flow_orchestration_parity_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class TraceNode extends Node {
  final String id;
  final dynamic actionToReturn;
  TraceNode(this.id, this.actionToReturn);

  @override
  Future<dynamic> exec(dynamic prepRes) async {
    final shared = prepRes is Map<String, dynamic> ? prepRes : {};
    (shared['trace'] as List).add(id);
    return actionToReturn;
  }

  @override
  BaseNode createInstance() => TraceNode(id, actionToReturn);
}

void main() {
  test('Flow orchestration sequence and actions match Python', () async {
    final trace = <String>[];
    final shared = <String, dynamic>{'trace': trace};

    final a = TraceNode('A', 'toB');
    final b = TraceNode('B', 'toC');
    final c = TraceNode('C', null);

    a.next(b, 'toB');
    b.next(c, 'toC');

    final flow = Flow(start: a);
    final result = await flow.run(shared);
    expect(trace, equals(['A', 'B', 'C']));
    expect(result, isNull);
  });
}
```

---

## 2) `test/batch_flow_parity_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class RecordingNode extends Node {
  RecordingNode();

  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    // record current params into shared.traceParams for test
    final trace = shared.putIfAbsent('traceBatch', () => <dynamic>[]) as List;
    trace.add(Map.from(params ?? {}));
    return shared;
  }

  @override
  Future<dynamic> exec(dynamic prepRes) async {
    return null;
  }

  @override
  BaseNode createInstance() => RecordingNode();
}

void main() {
  test('BatchFlow returns post(..., exec_res=null) and respects params', () async {
    final shared = <String, dynamic>{'items': [{'x':1}, {'x':2}, {'x':3}], 'traceBatch': []};
    final node = RecordingNode();
    final flow = BatchFlow(node);

    final out = await flow.run(shared);
    // Python BatchFlow.post by default returns exec_res which was None
    expect(out, isNull);

    final trace = shared['traceBatch'] as List;
    expect(trace.length, equals(3));
    // check first recorded param has 'x' == 1
    expect(trace[0]['x'], equals(1));
  });
}
```

---

## 3) `test/async_flow_with_mixed_nodes_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class SyncRecorder extends Node {
  final String id;
  SyncRecorder(this.id);
  @override
  Future<dynamic> exec(dynamic prep) async {
    (prep as Map<String, dynamic>)['trace'].add(id);
    return null;
  }
  @override BaseNode createInstance() => SyncRecorder(id);
}

class AsyncRecorder extends AsyncNode {
  final String id;
  AsyncRecorder(this.id);
  @override
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return shared;
  }
  @override
  Future<dynamic> execAsync(dynamic prep) async {
    (prep as Map<String, dynamic>)['trace'].add(id);
    return null;
  }
  @override BaseNode createInstance() => AsyncRecorder(id);
}

void main() {
  test('AsyncFlow awaits both async and sync nodes in order', () async {
    final shared = <String, dynamic>{'trace': []};
    final a = AsyncRecorder('A');
    final b = SyncRecorder('B');
    final c = AsyncRecorder('C');
    a.next(b);
    b.next(c);
    final flow = AsyncFlow(start: a);
    final result = await flow.runAsync(shared);
    expect(shared['trace'], equals(['A','B','C']));
    expect(result, isNull);
  });
}
```

---

## 4) `test/retry_and_fallback_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class FailNTimesNode extends Node {
  int failsRemaining;
  FailNTimesNode(this.failsRemaining, {int maxRetries = 3}) {
    this.maxRetries = maxRetries;
  }

  @override
  Future<dynamic> exec(dynamic prep) async {
    if (failsRemaining > 0) {
      failsRemaining -= 1;
      throw Exception('failed');
    }
    return 'ok';
  }

  @override
  Future<dynamic> execFallback(dynamic prepRes, Object exc) async {
    return 'fallback:${exc.toString()}';
  }

  @override
  BaseNode createInstance() => FailNTimesNode(failsRemaining, maxRetries: maxRetries);
}

void main() {
  test('Node retries then fallback/success as Python', () async {
    final node = FailNTimesNode(2, maxRetries: 3);
    final shared = <String, dynamic>{};
    final res = await node.run(shared);
    expect(res, equals('ok'));

    final node2 = FailNTimesNode(3, maxRetries: 3);
    final res2 = await node2.run(shared);
    expect(res2.toString().startsWith('fallback'), isTrue);
  });
}
```

---

## 5) `test/cloning_and_node_params_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class MutatingNode extends Node {
  @override
  Future<dynamic> exec(dynamic prep) async {
    params['mut'] = (params['mut'] ?? 0) + 1;
    return null;
  }

  @override
  BaseNode createInstance() => MutatingNode();
}

void main() {
  test('Per-visit clones: mutations do not leak across visits', () async {
    final shared = <String, dynamic>{'items': [1,2]};
    final node = MutatingNode();
    final flow = BatchFlow(node);
    final result = await flow.run(shared);
    expect(result, isNull);
    // original node instance should not have mutated params
    expect(node.params == null || node.params['mut'] == null, isTrue);
  });
}
```

---

## 6) `test/parallel_batch_flow_shape_test.dart`

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class EchoNode extends Node {
  @override
  Future<dynamic> exec(dynamic prep) async => prep;
  @override BaseNode createInstance() => EchoNode();
}

void main() {
  test('AsyncParallelBatchFlow returns list-of-results and is documented', () async {
    final flow = AsyncParallelBatchFlow([EchoNode()], copySharedForParallel: true);
    final res = await flow.call([{'x': 1}, {'x': 2}]);
    expect(res, isA<List>()); // the result is a list of results per item
  });
}
```

---

## 7) `test/loop_guard_test.dart` (new)

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class LoopNode extends Node {
  final String id;
  LoopNode(this.id);
  @override
  Future<dynamic> exec(dynamic prep) async {
    (prep as Map<String, dynamic>)['trace'].add(id);
    return 'loop';
  }
  @override BaseNode createInstance() => LoopNode(id);
}

void main() {
  test('Flow throws when exceeding maxSteps (loop guard)', () async {
    final shared = <String, dynamic>{'trace': []};
    final a = LoopNode('A');
    // A points to itself on 'loop' action
    a.next(a, 'loop');

    final flow = Flow(start: a);
    expect(() => flow.orch(shared, null, 10), throwsA(isA<StateError>()));
  });
}
```

> Note: This assumes you added `orch(shared, params, maxSteps)` signature. If your API differs, adapt test.

---

## 8) `test/parallel_shared_race_test.dart` (new concurrency race test)

```dart
import 'dart:async';
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class ConcurrencyNode extends AsyncNode {
  final int id;
  ConcurrencyNode(this.id);

  @override
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async {
    return shared;
  }

  @override
  Future<dynamic> execAsync(dynamic prep) async {
    final shared = prep as Map<String, dynamic>;
    final before = shared.putIfAbsent('counter', () => 0) as int;
    // simulate async delay
    await Future.delayed(Duration(milliseconds: 10));
    shared['counter'] = before + 1;
    return null;
  }

  @override
  BaseNode createInstance() => ConcurrencyNode(id);
}

void main() {
  test('AsyncParallelBatchFlow with copySharedForParallel avoids race', () async {
    final shared = <String, dynamic>{'counter': 0};
    final items = List.generate(10, (i) => {'id': i});
    final nodes = [ConcurrencyNode(0)];
    final flowCopy = AsyncParallelBatchFlow(nodes, copySharedForParallel: true);
    await flowCopy.call(items);
    // when copied per-task, shared.counter remains unchanged (or is only used for each copy)
    // The global shared counter should not be incremented by per-task copies
    expect(shared['counter'], equals(0));

    final flowNoCopy = AsyncParallelBatchFlow(nodes, copySharedForParallel: false);
    // If not copying, concurrent increments may race but final count should be 10
    shared['counter'] = 0;
    await flowNoCopy.call(items);
    expect(shared['counter'], equals(10));
  }, timeout: Timeout(Duration(seconds: 5)));
}
```

**Why:** ensures default safe behavior, and explicit `false` exposes race semantics for those who want it.

---

## 9) `test/async_node_retry_fallback_test.dart` (new)

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class AsyncFailNTimes extends AsyncNode {
  int failsRemaining;
  AsyncFailNTimes(this.failsRemaining, {int maxRetries = 3}) {
    this.maxRetries = maxRetries;
  }

  @override
  Future<dynamic> prepAsync(Map<String, dynamic> shared) async => shared;

  @override
  Future<dynamic> execAsync(dynamic prep) async {
    if (failsRemaining > 0) {
      failsRemaining -= 1;
      throw Exception('async fail');
    }
    return 'ok';
  }

  @override
  Future<dynamic> execFallbackAsync(dynamic prepRes, Object exc) async {
    return 'fallback:${exc.toString()}';
  }

  @override
  BaseNode createInstance() => AsyncFailNTimes(failsRemaining, maxRetries: maxRetries);
}

void main() {
  test('AsyncNode retries then fallback or succeeds', () async {
    final node = AsyncFailNTimes(2, maxRetries: 3);
    final shared = <String, dynamic>{};
    final res = await node.runAsync(shared);
    expect(res, equals('ok'));

    final node2 = AsyncFailNTimes(3, maxRetries: 3);
    final res2 = await node2.runAsync(shared);
    expect(res2.toString().startsWith('fallback'), isTrue);
  });
}
```

---

## 10) `test/params_precedence_test.dart` (new)

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class CheckParamsNode extends Node {
  @override
  Future<dynamic> prep(Map<String, dynamic> shared) async {
    shared['observed'] = Map<String, dynamic>.from(params ?? {});
    return shared;
  }

  @override
  Future<dynamic> exec(dynamic prep) async => null;

  @override
  BaseNode createInstance() => CheckParamsNode();
}

void main() {
  test('Params precedence: explicit params override flow.params and __node_params__', () async {
    final shared = <String, dynamic>{};
    final node = CheckParamsNode();
    final flow = Flow(start: node);
    // set flow.params
    flow.params = {'a': 1, 'b': 1};
    // simulate __node_params__ map but we assume parity mode ignores this unless enabled
    shared['__node_params__'] = {'CheckParamsNode': {'b': 2, 'c': 3}};

    final out = await flow.orch(shared, {'b': 9}); // explicit params override both
    expect(shared['observed']['a'], equals(1)); // from flow.params
    expect(shared['observed']['b'], equals(9)); // overridden by explicit
    expect(shared['observed'].containsKey('c'), isFalse); // node-specific ignored by default
  });
}
```

**Decision:** This test verifies precedence: `explicit params` > `flow.params` > `__node_params__` (unless `applyNodeParams` enabled).

---

## 11) `test/null_empty_flow_test.dart` (new)

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class NoopNode extends Node {
  @override
  Future<dynamic> exec(dynamic prep) async => null;
  @override BaseNode createInstance() => NoopNode();
}

void main() {
  test('Flow with null start throws or returns null gracefully', () async {
    // If start is null, calling run should throw or return null depending on Python behavior.
    final flow = Flow(start: null);
    expect(() => flow.run(<String, dynamic>{}), throwsA(isA<StateError>()));
  });

  test('Empty batch (items == []) results in post called with empty prep list', () async {
    final shared = <String, dynamic>{'items': []};
    final node = NoopNode();
    final flow = BatchFlow(node);
    final out = await flow.run(shared);
    expect(out, isNull); // post(..., exec_res=null)
  });
}
```

---

## 12) `test/identity_clone_semantics_test.dart` (new)

```dart
import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class IdentityNode extends Node {
  @override
  Future<dynamic> exec(dynamic prep) async => null;
  @override BaseNode createInstance() => IdentityNode();
}

void main() {
  test('Nodes are shallow-cloned per-visit (identity differs)', () async {
    final start = IdentityNode();
    final next = IdentityNode();
    start.next(next);
    final flow = Flow(start: start);

    // run once to ensure clones created
    final shared = <String, dynamic>{};
    await flow.run(shared);

    // original nodes should be distinct from those visited; we check that the original
    // 'start' object != the node referenced internally after orchestration.
    // Because orchestration clones per visit, the original start should remain unchanged.
    expect(start, isNot(same(flow.start)));
  });
}
```

> Adjust this test if `flow.start` is intentionally mutated; the goal is to assert clone semantics do not reuse same object for visits.

---

# Test helpers & notes

* If tests reference `flow.orch(shared, params, maxSteps)` you must add that API (or adjust tests to call existing function signature).
* If your `Flow` API names differ (e.g., `start_node` vs `start`) adapt import and instantiation accordingly.
* Some tests assume `AsyncNode` exposes `runAsync` and `run` — if your port uses different names use the ported names.

---

# CI snippet (GitHub Actions) — minimal

`.github/workflows/dart-test.yml`:

```yaml
name: Dart tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: 'stable'
      - run: dart pub get
      - run: dart test --concurrency=4
```

---

# PR checklist (must pass before merge)

* [ ] Branch `parity/tests-and-fixes` created.
* [ ] `BatchFlow.run` changed to parity implementation.
* [ ] `Flow.orch` changed to shallow copy-on-demand and `maxSteps` guard added.
* [ ] `AsyncParallelBatchFlow` has `copySharedForParallel` flag and defaulted `true`.
* [ ] All 12 test files added under `test/`.
* [ ] `dart test` passes locally.
* [ ] CI (GitHub Actions) passing.
* [ ] README/CHANGELOG updated describing parity choices:

  * BatchFlow returns `post(..., exec_res=null)`.
  * Flow uses shallow clone per visit.
  * AsyncParallelBatchFlow copies `shared` per task by default.
  * `maxSteps` guard for infinite loop protection.
* [ ] Version bump if API changed (major version if breaking).

---

# Priority order (what to implement, in this exact order)

1. **Implement `BatchFlow.run` change** (biggest semantic difference). Add tests `batch_flow_parity_test.dart`. Run tests — expect failures elsewhere.
2. **Implement `Flow.orch` shallow cloning + `maxSteps` guard**. Add `flow_orchestration_parity_test.dart` and `loop_guard_test.dart`.
3. **Implement `AsyncParallelBatchFlow` shared-copy behavior**. Add `parallel_shared_race_test.dart` and `parallel_batch_flow_shape_test.dart`.
4. **Add Node retry/fallback parity for sync and async**. Add `retry_and_fallback_test.dart` and `async_node_retry_fallback_test.dart`.
5. **Add cloning/params tests**: `cloning_and_node_params_test.dart`, `params_precedence_test.dart`, `identity_clone_semantics_test.dart`.
6. **Add async+sync mixed orchestration**: `async_flow_with_mixed_nodes_test.dart`.
7. **Add null/empty tests**: `null_empty_flow_test.dart`.
8. Fix failing tests iteratively.
9. Run performance check for big batches (optional heavy test).

---

# Risk matrix & mitigations

* **BatchFlow change** — high impact: run all dependent tests and update docs. Mitigation: TDD-first (write failing tests).
* **Clone semantics** — high risk for consumers using identity checks. Mitigation: add identity tests and document behavior; consider providing an API to preserve identity if needed.
* **Parallel shared mutation** — medium risk for concurrency bugs. Mitigation: copy shared by default; provide flag for advanced users.
* **Infinite loops** — medium risk. Mitigation: `maxSteps` guard and test.
* **API breakage** — medium risk. Mitigation: bump major version and list breaking changes.

---

# Extra developer notes (no sugar)

* Tests are intentionally defensive — they will reveal hidden assumptions in the port. Don’t ignore failing tests — they’re telling you where behavior diverges.
* Prefer *explicit* behavior (flags, docs) rather than implicit magical behavior. That prevents subtle bugs.
* If you want, I can also generate the **exact git patch/diff** for `BatchFlow.run`, `Flow.orch`, and `AsyncParallelBatchFlow` changes. Say “generate patches” and I’ll spit out unified diffs.

---

# Next steps — pick one

1. I generate **code patches** (diffs) for the three code changes listed.
2. I generate the **12 test files** as actual files in one message (they’re above already).
3. I generate both patches + tests together.

Tell me “patches”, “tests”, or “both” and I’ll output exactly what you asked for. I won’t start editing your repo — I’ll produce copy-paste-ready diffs and test files.
