import 'base_item.dart';
import 'item_stack.dart';

class Inventory {
  Inventory({
    required this.id,
    List<ItemStack>? initialItems,
  }) : _items = initialItems ?? <ItemStack>[];

  final String id;
  final List<ItemStack> _items;

  List<ItemStack> get items => _items;

  bool contains(BaseItem item) {
    return _items.any((ItemStack inventoryItem) => inventoryItem.item == item);
  }

  ItemStack? get(BaseItem item) {
    try {
      return _items
          .firstWhere((ItemStack inventoryItem) => inventoryItem.item == item);
    } catch (e) {
      return null;
    }
  }

  void add(ItemStack itemsToAdd) {
    final ItemStack? preExistingItem = get(itemsToAdd.item);
    if (preExistingItem != null) {
      updateItemCount(itemsToAdd.item, itemsToAdd.count);
    } else {
      _items.add(itemsToAdd.copyWith());
    }
  }

  void addAll(List<ItemStack> items) {
    // ignore: avoid_function_literals_in_foreach_calls
    items.forEach((ItemStack item) => add(item));
  }

  void updateItemCount(BaseItem item, int change) {
    final ItemStack? inventoryItem = get(item);
    if (inventoryItem != null) {
      inventoryItem.addToCount(change);
    }

    if (inventoryItem?.count == 0) {
      _items.remove(inventoryItem);
    }
  }
}
