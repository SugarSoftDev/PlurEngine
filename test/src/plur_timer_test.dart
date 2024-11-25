import 'package:plur_engine/plur_engine.dart' show PlurTimer;
import 'package:plur_engine/src/common_typedefs.dart';
import 'package:test/test.dart';

void main() {
  group('PlurTimer', () {
    late PlurTimer timer;

    setUp(() {
      timer = PlurTimer();
    });

    test('initializes with default ticks per second', () {
      expect(timer.ticksPerSecond, equals(PlurTimer.defaultTicksPerSecond));
    });

    test('initializes with zero session ticks', () {
      expect(timer.sessionTicks, equals(0));
    });

    test('changes ticks per second', () {
      const int newTicksPerSecond = 20;
      timer.changeTicksPerSecond(newTicksPerSecond);
      expect(timer.ticksPerSecond, equals(newTicksPerSecond));
      expect(timer.timerInterval.inMilliseconds,
          equals(1000 ~/ newTicksPerSecond));
    });

    test('adds on tick callback', () {
      void callback() {}
      timer.addOnTickCallback(callback);
      expect(timer.onTickCallbacks.contains(callback), isTrue);
    });

    test('removes on tick callback', () {
      void callback() {}

      final VoidCallback removeCallback = timer.addOnTickCallback(callback);
      expect(timer.onTickCallbacks.contains(callback), isTrue);

      removeCallback();
      expect(timer.onTickCallbacks.contains(callback), isFalse);
    });

    test('adds on duration callback', () {
      void callback() {}
      const Duration interval = Duration(seconds: 1);
      timer.addOnDurationCallback(interval, callback);
      expect(timer.getOnDurationCallbacks(interval)?.contains(callback), isTrue);
    });

    test('removes on duration callback', () {
      void callback() {}
      const Duration interval = Duration(seconds: 1);
      final VoidCallback removeCallback =
          timer.addOnDurationCallback(interval, callback);
      expect(timer.getOnDurationCallbacks(interval)?.contains(callback), isTrue);

      removeCallback();
      expect(timer.getOnDurationCallbacks(interval)?.contains(callback), isFalse);
    });

    test('removes only the correct callback', () {
      void callback() {}
      void callback2() {}

      final VoidCallback removeCallback = timer.addOnTickCallback(callback);
      timer.addOnTickCallback(callback2);
      expect(timer.onTickCallbacks.contains(callback), isTrue);
      expect(timer.onTickCallbacks.contains(callback2), isTrue);

      removeCallback();
      expect(timer.onTickCallbacks.contains(callback), isFalse);
      expect(timer.onTickCallbacks.contains(callback2), isTrue);
    });

    test(
        'duplicates a callback if it is added twice, and the removal only removes the one added by that reference',
        () {
      void callback() {}

      final VoidCallback removeCallback = timer.addOnTickCallback(callback);
      final VoidCallback removeCallback2 = timer.addOnTickCallback(callback);

      expect(timer.onTickCallbacks.contains(callback), isTrue);
      removeCallback();
      expect(timer.onTickCallbacks.contains(callback), isTrue);
      removeCallback2();
      expect(timer.onTickCallbacks.contains(callback), isFalse);
    });

    group('validateTimeInterval', () {
      test('returns Duration.zero for negative intervals', () {
        final PlurTimer timer = PlurTimer();
        const Duration interval = Duration(milliseconds: -100);
        expect(timer.validateTimeInterval(interval), equals(Duration.zero));
      });

      test(
          'returns the original interval if it is a multiple of millisecondsPerTick',
          () {
        final PlurTimer timer = PlurTimer();
        final Duration interval =
            Duration(milliseconds: timer.millisecondsPerTick);
        expect(timer.validateTimeInterval(interval), equals(interval));
      });

      test(
          'rounds down intervals that are not multiples of millisecondsPerTick',
          () {
        final PlurTimer timer = PlurTimer();
        final Duration interval =
            Duration(milliseconds: timer.millisecondsPerTick + 1);
        final Duration expectedInterval =
            Duration(milliseconds: timer.millisecondsPerTick);
        expect(timer.validateTimeInterval(interval), equals(expectedInterval));
      });

      test('rounds up intervals that are not multiples of millisecondsPerTick',
          () {
        final PlurTimer timer = PlurTimer();
        final Duration interval =
            Duration(milliseconds: timer.millisecondsPerTick - 1);
        final Duration expectedInterval =
            Duration(milliseconds: timer.millisecondsPerTick);
        expect(timer.validateTimeInterval(interval), equals(expectedInterval));
      });
    });
  });
}
