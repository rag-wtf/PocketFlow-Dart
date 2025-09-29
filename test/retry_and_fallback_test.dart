import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class FailNTimesNode extends Node {
  int failsRemaining;
  FailNTimesNode(
    this.failsRemaining, {
    int maxRetries = 3,
    Duration wait = Duration.zero,
  }) : super(maxRetries: maxRetries, wait: wait);

  @override
  Future<dynamic> exec(dynamic prepResult) async {
    if (failsRemaining > 0) {
      failsRemaining--;
      throw Exception('Simulated failure, $failsRemaining failures remaining');
    }
    return 'success';
  }

  @override
  Future<dynamic> execFallback(dynamic prepResult, Exception error) async {
    return 'fallback_executed';
  }

  @override
  BaseNode createInstance() =>
      FailNTimesNode(failsRemaining, maxRetries: maxRetries);
}

void main() {
  test('Node should retry and eventually succeed', () async {
    final node = FailNTimesNode(
      2,
      maxRetries: 3,
    ); // Fail 2 times, succeed on 3rd
    final shared = <String, dynamic>{};

    final result = await node.run(shared);
    expect(result, equals('success'));
  });

  test('Node should use fallback when retries exhausted', () async {
    final node = FailNTimesNode(5, maxRetries: 2); // Fail more than max retries
    final shared = <String, dynamic>{};

    final result = await node.run(shared);
    expect(result, equals('fallback_executed'));
  });

  test('Node should respect retry delay', () async {
    final node = FailNTimesNode(
      1,
      maxRetries: 2,
      wait: const Duration(milliseconds: 10),
    );

    final shared = <String, dynamic>{};
    final stopwatch = Stopwatch()..start();

    await node.run(shared);
    stopwatch.stop();

    // Should have taken at least the retry delay
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
  });
}
