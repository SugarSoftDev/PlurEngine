import 'package:reliable_interval_timer/reliable_interval_timer.dart';
import 'common_typedefs.dart';

class PlurTimer {
  // Singleton instance
  factory PlurTimer() => _singleton;
  PlurTimer._internal() {
    _timer = ReliableIntervalTimer(
      interval: Duration(milliseconds: millisecondsPerTick),
      callback: _onTick,
    );
    _onTickCallbacks.add(_onInterval);
    _generateTickLookupTable();
  }
  static final PlurTimer _singleton = PlurTimer._internal();

  // constants
  static const int millisecondsPerSecond = 1000;
  static const int defaultTicksPerSecond = 20;

  // private properties
  late ReliableIntervalTimer _timer;
  int _sessionTicks = 0;
  int _ticksPerSecond = defaultTicksPerSecond;
  final List<void Function()> _onTickCallbacks = <void Function()>[];
  final Map<int, List<VoidCallback>> _onIntervalCallbacks =
      <int, List<VoidCallback>>{};
  final Map<int, int> _tickLookupTable = <int, int>{};

  // getters
  int get ticks => _sessionTicks;
  int get ticksPerSecond => _ticksPerSecond;
  int get millisecondsPerTick => millisecondsPerSecond ~/ _ticksPerSecond;
  int get sessionTicks => _sessionTicks;
  List<VoidCallback> get onTickCallbacks => _onTickCallbacks;
  Map<int, List<VoidCallback>> get onIntervalCallbacks => _onIntervalCallbacks;
  Duration get timerInterval => _timer.interval;
  int get minActionTicks => 5;
  Duration get minActionDuration =>
      Duration(milliseconds: millisecondsPerTick * minActionTicks);

// public methods
  Future<void> start() {
    if (!_timer.isRunning) {
      return _timer.start();
    }
    return Future<void>.value();
  }

  Future<void> stop() {
    if (_timer.isRunning) {
      return _timer.stop();
    }
    return Future<void>.value();
  }

  void simulateTick() => _onTick(millisecondsPerTick);
  void simulateNTicks(int n) {
    for (int i = 0; i < n; i++) {
      _onTick(millisecondsPerTick);
    }
  }

  List<VoidCallback>? getOnDurationCallbacks(Duration interval) =>
      _onIntervalCallbacks[_millisecondsToTicks(
        validateTimeInterval(interval).inMilliseconds,
      )];

  /// Adds a callback to be called when the timer ticks.
  ///
  /// The callback takes no arguments and returns no value.
  ///
  /// The returned value is a function that can be called to remove the callback.
  ///
  /// This is useful for objects that live for a shorter time than the timer and
  /// need to register temporary callbacks.
  VoidCallback addOnTickCallback(VoidCallback callback) {
    _onTickCallbacks.add(callback);
    void removeCallback() {
      _onTickCallbacks.remove(callback);
    }

    return removeCallback;
  }

  /// Adds a callback to be called every [interval] milliseconds.
  ///
  /// The callback takes no arguments and returns no value.
  ///
  /// The returned value is a function that can be called to remove the callback.
  ///
  /// This is useful for objects that live for a shorter time than the timer and
  /// need to register temporary callbacks.
  VoidCallback addOnDurationCallback(Duration interval, VoidCallback callback) {
    final Duration validatedInterval = validateTimeInterval(interval);
    final int intervalTicks =
        _millisecondsToTicks(validatedInterval.inMilliseconds);
    return _addOnIntervalCallback(intervalTicks, callback);
  }

  /// Changes the rate at which the timer ticks.
  ///
  /// [newTicksPerSecond] is the number of times the timer should tick per second.
  void changeTicksPerSecond(int newTicksPerSecond) {
    _ticksPerSecond = newTicksPerSecond;
    _timer.interval = Duration(milliseconds: millisecondsPerTick);
    _generateTickLookupTable();
  }

  /// Rounds [interval] to the closest duration that is a multiple of
  /// [millisecondsPerTick].
  ///
  /// If [interval] is negative, returns [Duration.zero].
  ///
  /// This is useful for rounding intervals to a duration that can be used with
  /// the timer.
  Duration validateTimeInterval(Duration interval) {
    if (interval.isNegative) {
      return Duration.zero;
    }
    final int seconds = interval.inSeconds;
    final int millisecondsLeft =
        interval.inMilliseconds % millisecondsPerSecond;
    final double preciseTicks = millisecondsLeft / millisecondsPerTick;
    if (_tickLookupTable.containsKey(preciseTicks)) {
      return interval;
    }
    final int roundedMilliseconds =
        (millisecondsLeft / millisecondsPerTick).round() * millisecondsPerTick;
    return Duration(seconds: seconds, milliseconds: roundedMilliseconds);
  }

  /// Returns [interval] if it is not shorter than [minActionDuration], or
  /// [minActionDuration] otherwise.
  ///
  /// This is useful for ensuring that an interval is never shorter than the
  /// minimum action duration.
  Duration maxActionDuration(Duration interval) =>
      interval < minActionDuration ? minActionDuration : interval;

  // private methods
  void _onTick(int msDelta) {
    _sessionTicks++;
    for (final void Function() callback in _onTickCallbacks) {
      callback();
    }
  }

  void _onInterval() {
    _onIntervalCallbacks.forEach(
      (int key, List<void Function()> value) {
        if (_sessionTicks % key == 0) {
          for (final void Function() callback in value) {
            callback();
          }
        }
      },
    );
  }

  VoidCallback _addOnIntervalCallback(int interval, VoidCallback callback) {
    _onIntervalCallbacks.putIfAbsent(interval, () => <VoidCallback>[]);
    _onIntervalCallbacks[interval]!.add(callback);
    void removeCallback() {
      _onIntervalCallbacks[interval]!.remove(callback);
    }

    return removeCallback;
  }

  int _ticksToMilliseconds(int ticks) => ticks * millisecondsPerTick;

  int _millisecondsToTicks(int milliseconds) =>
      milliseconds ~/ millisecondsPerTick;

  void _generateTickLookupTable() {
    _tickLookupTable.clear();
    for (int i = 0; i < _ticksPerSecond; i++) {
      _tickLookupTable[_ticksToMilliseconds(i)] = i;
    }
  }
}
