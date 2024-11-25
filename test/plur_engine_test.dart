import 'package:plur_engine/plur_engine.dart';
import 'package:test/test.dart';

void main() {
  group('PlurEngine', () {
    final PlurEngine engine = PlurEngine();

    test('has a timer', () {
      expect(engine.timer, isNotNull);
    });
  });
}
