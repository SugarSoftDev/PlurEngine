import 'dart:math';

import '../items/item_stack.dart';

typedef BuffsMap = Map<String, ActionBuffs>;

class ActionBuffs {
  ActionBuffs(
    this.sourceId, {
    double doubleChance = 0,
    this.rewardMultipliers = const <int>[],
  }) {
    _doubleChance = validateDoubleChance(doubleChance);
  }

  final String sourceId;

  final List<int> rewardMultipliers;

  late double _doubleChance;

  ActionBuffs addTo(ActionBuffs other) {
    return ActionBuffs(
      '$sourceId + ${other.sourceId}',
      doubleChance: _doubleChance + other._doubleChance,
      rewardMultipliers: <int>[
        ...rewardMultipliers,
        ...other.rewardMultipliers
      ],
    );
  }

  ItemStack applyDoubleChance(ItemStack reward) {
    final Random r = Random();
    if (r.nextDouble() < _doubleChance) {
      reward.multiplyCount(2);
      return reward;
    } else {
      return reward;
    }
  }

  ItemStack applyRewardMultipliers(ItemStack reward) {
    if (rewardMultipliers.isEmpty) {
      return reward;
    }

    final int reducedMultiplier =
        rewardMultipliers.reduce((int a, int b) => a + b);

    reward.multiplyCount(reducedMultiplier);
    return reward;
  }

  double validateDoubleChance(double chance) {
    if (chance < 0) {
      return 0;
    }
    if (chance > 1) {
      return 1;
    }
    return chance;
  }
}
