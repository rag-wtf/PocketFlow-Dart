import 'package:test/test.dart';
import 'package:pocketflow/pocketflow.dart';

class AsyncFailNTimes extends AsyncNode {
  int failsRemaining;
  AsyncFailNTimes(
    this.failsRemaining, {
    int maxRetries = 3,
    Duration wait = Duration.zero,
  }) : super(maxRetries: maxRetries, wait: wait);

  @override
  Future<dynamic> execAsync(dynamic prepResult) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (failsRemaining > 0) {
      failsRemaining--;
      throw Exception('Async failure, $failsRemaining failures remaining');
    }
    return 'async_success';
  }

  @override
  Future<dynamic> execFallbackAsync(dynamic prepResult, Exception error) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return 'async_fallback_executed';
  }

  @override
  BaseNode createInstance() =>
      AsyncFailNTimes(failsRemaining, maxRetries: maxRetries, wait: wait);
}

void main() {
  test('AsyncNode should retry and eventually succeed', () async {
    final node = AsyncFailNTimes(
      2,
      maxRetries: 3,
    ); // Fail 2 times, succeed on 3rd
    final shared = <String, dynamic>{};

    final result = await node.run(shared);
    expect(result, equals('async_success'));
  });

  test('AsyncNode should use fallback when retries exhausted', () async {
    final node = AsyncFailNTimes(
      5,
      maxRetries: 2,
    ); // Fail more than max retries
    final shared = <String, dynamic>{};

    final result = await node.run(shared);
    expect(result, equals('async_fallback_executed'));
  });

  test('AsyncNode should respect retry delay', () async {
    final node = AsyncFailNTimes(
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
