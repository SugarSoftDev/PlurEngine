import 'base_item.dart';

class ItemStack {
  ItemStack(
    this.item,
    int initialCount,
  ) : _count = item.validateStack(initialCount);

  final BaseItem item;
  int _count;

  int get count => _count;

  int addToCount(int change) {
    final int newCount = item.validateStack(_count + change);
    _count = newCount;
    return newCount;
  }

  int multiplyCount(int change) {
    final int newCount = item.validateStack(_count * change);
    _count = newCount;
    return newCount;
  }

  ItemStack copyWith({int? count}) {
    return ItemStack(item, count ?? _count);
  }
}
