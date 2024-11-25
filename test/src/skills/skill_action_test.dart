import 'package:plur_engine/plur_engine.dart'
    show Inventory, PlurTimer, SkillAction, Currency, ActionBuffs;
import 'package:test/test.dart';

void main() {
  group('SkillAction', () {
    const String sourceId = 'test';

    late PlurTimer timer;
    late Inventory inventory;
    final Currency cash =
        Currency(id: 'cash', name: 'Test Cash', description: 'Test Cash');

    setUp(() {
      timer = PlurTimer();
      inventory = Inventory(id: 'test_inventory');
    });

    test(
        'startAction adds an item to the inventory in the correct amount of time',
        () {
      final SkillAction action = SkillAction(
        baseDuration: timer.minActionDuration,
        inventory: inventory,
        consistentSingleReward: cash,
      );

      action.startAction();

      int simulatedTicksRequired = 0;
      // Simulate the timer advancing until the reward item has been added to the inventory
      while (!inventory.contains(cash)) {
        simulatedTicksRequired++;
        timer.simulateTick();
      }

      expect(simulatedTicksRequired, equals(timer.minActionTicks));
    });

    test('no buffs means that the consistentSingleReward is added as is', () {
      final ActionBuffs buff = ActionBuffs(sourceId);
      final SkillAction action = SkillAction(
        baseDuration: timer.minActionDuration,
        inventory: inventory,
        consistentSingleReward: cash,
        buffs: <String, ActionBuffs>{sourceId: buff},
      );

      action.startAction();

      timer.simulateNTicks(timer.minActionTicks);
      expect(inventory.contains(cash), isTrue);
      expect(inventory.get(cash)?.count, equals(1));
    });

    test('buffs are applied to the consistentSingleReward', () {
      final ActionBuffs buff = ActionBuffs(sourceId, doubleChance: 1);
      final SkillAction action = SkillAction(
        baseDuration: timer.minActionDuration,
        inventory: inventory,
        consistentSingleReward: cash,
        buffs: <String, ActionBuffs>{sourceId: buff},
      );

      action.startAction();

      timer.simulateNTicks(timer.minActionTicks);
      expect(inventory.contains(cash), isTrue);
      expect(inventory.get(cash)?.count, equals(2));
    });

    test('buffs can change after startAction and apply correctly', () {
      final ActionBuffs initialBuff = ActionBuffs(sourceId);
      final SkillAction action = SkillAction(
        baseDuration: timer.minActionDuration,
        inventory: inventory,
        consistentSingleReward: cash,
        buffs: <String, ActionBuffs>{sourceId: initialBuff},
      );

      action.startAction();

      timer.simulateNTicks(timer.minActionTicks);
      expect(inventory.contains(cash), isTrue);
      expect(inventory.get(cash)?.count, equals(1));

      final ActionBuffs newBuff = ActionBuffs(sourceId, doubleChance: 1);
      action.updateCalculations(<String, ActionBuffs>{sourceId: newBuff});
      timer.simulateNTicks(timer.minActionTicks);
      expect(inventory.get(cash)?.count, equals(3));

      action.updateCalculations(<String, ActionBuffs>{sourceId: initialBuff});
      timer.simulateNTicks(timer.minActionTicks);
      expect(inventory.get(cash)?.count, equals(4));
    });
  });
}
