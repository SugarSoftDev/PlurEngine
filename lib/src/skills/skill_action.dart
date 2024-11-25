import '../common_typedefs.dart';
import '../items/base_item.dart';
import '../items/inventory.dart';
import '../items/item_stack.dart';
import '../plur_timer.dart';
import 'action_buffs.dart';

class SkillAction {
  SkillAction({
    required this.baseDuration,
    required this.inventory,
    BuffsMap buffs = const <String, ActionBuffs>{},
    this.consistentSingleReward,
  }) : _buffs = buffs;

  // parameters
  final Duration baseDuration;
  final Inventory inventory;

  // Rewards - Do not ever pass in rewards as Items
  // Instead, pass in the reward as a raw BaseItem or List<BaseItem>
  // Create a new Items in the _calculateRewards method
  final BaseItem? consistentSingleReward;

  // private properties
  final BuffsMap _buffs;
  final PlurTimer _timer = PlurTimer();
  late Duration _interval = _calculateDuration();
  VoidCallback? _stopCallback;

  // getters
  BuffsMap get buffs => _buffs;

  // public methods
  void toggleAction() {
    if (_stopCallback == null) {
      _interval = _calculateDuration();
      startAction();
    } else {
      stopAction();
    }
  }

  /// Starts the skill action, which begins the timer and sets up the callback.
  ///
  /// When the interval is reached, the callback will be called, which will perform the
  /// action by adding the rewards to the inventory.
  ///
  /// The timer will be set to the calculated duration, which will be the
  /// duration of the action.
  void startAction() {
    // Create the callback to perform the action
    void performAction() {
      final List<ItemStack> rewards = _calculateRewards();
      inventory.addAll(rewards);
    }

    // Register the callback with the timer
    _stopCallback = _timer.addOnDurationCallback(_interval, performAction);
  }

  /// Stops the skill action, which removes the callback from the timer
  /// and resets the `_stopCallback` to null.
  ///
  /// If the skill action is not running, this does nothing.
  void stopAction() {
    if (_stopCallback == null) {
      return;
    }

    _stopCallback!();
    _stopCallback = null;
  }

  /// Updates the internal calculations of the skill action based on the new buffs.
  ///
  /// This updates the internal duration and rewards of the skill action, and
  /// restarts the timer if the skill action is currently running.
  ///
  /// The timer is only stopped and restarted if the calculations have changed.
  ///
  /// [newBuffs] is a map from source id to action buffs.
  void updateCalculations(BuffsMap newBuffs) {
    bool calculationsChanged = false;

    _buffs.clear();
    _buffs.addAll(newBuffs);
    final Duration newInterval = _calculateDuration();

    if (newInterval != _interval) {
      _interval = newInterval;
      calculationsChanged = true;
    }

    if (calculationsChanged) {
      if (_stopCallback != null) {
        stopAction();
        startAction();
      }
    }
  }

  // private methods
  List<ItemStack> _calculateRewards() {
    final List<ItemStack> rewards = <ItemStack>[];
    if (_buffs.isNotEmpty) {
      final ActionBuffs combinedBuffs =
          _buffs.values.reduce((ActionBuffs a, ActionBuffs b) => a.addTo(b));
      if (consistentSingleReward != null) {
        final ItemStack rawReward = ItemStack(consistentSingleReward!, 1);
        ItemStack reward = combinedBuffs.applyDoubleChance(rawReward);
        reward = combinedBuffs.applyRewardMultipliers(reward);
        rewards.add(reward);
      }
    }
    if (_buffs.isEmpty) {
      if (consistentSingleReward != null) {
        final ItemStack rawReward = ItemStack(consistentSingleReward!, 1);
        rewards.add(rawReward);
      }
    }
    return rewards;
  }

  Duration _calculateDuration() {
    final Duration calculatedDuration = baseDuration;
    final Duration maxxedDuration =
        _timer.maxActionDuration(calculatedDuration);
    return maxxedDuration;
  }
}
