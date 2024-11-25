import 'plur_timer.dart';

/// The public API for PlurEngine.
class PlurEngine {
  factory PlurEngine() => _singleton;
  PlurEngine._internal();
  static final PlurEngine _singleton = PlurEngine._internal();

  final PlurTimer _timer = PlurTimer();
  PlurTimer get timer => _timer;

  void start() => _timer.start();
  void stop() => _timer.stop();
}
