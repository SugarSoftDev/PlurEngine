abstract class BaseItem {
  const BaseItem({
    required this.id,
    required this.name,
    required this.description,
    this.maxStack = 0,
  });

  final String id;
  final String name;
  final String description;
  final int maxStack;


  /// Returns [stack] if it is a valid stack size, otherwise returns the nearest
  /// valid stack size.
  ///
  /// A valid stack size is a non-negative number that is not larger than
  /// [maxStack].
  /// 
  /// If [maxStack] is 0, returns [stack] unchanged.
  int validateStack(int stack) {
    if (maxStack == 0) {
      return stack;
    }
    if (stack < 0) {
      return 0;
    }
    if (stack > maxStack) {
      return maxStack;
    }
    return stack;
  }
}
