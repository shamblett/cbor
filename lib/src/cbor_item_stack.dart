/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// A Dart item linked list entry for use by the stack
class ItemEntry<DartItem> extends LinkedListEntry {
  DartItem value;

  ItemEntry(this.value);

  String toString() => "${super.toString()} : value.toString()";
}

/// The decoded Dart item stack class.
class ItemStack {
  LinkedList _stack = new LinkedList();

  /// Push an item.
  void push(DartItem item) {
    final ItemEntry entry = new ItemEntry(item);
    _stack.addFirst(entry);
  }

  /// Pop an item from the stack top.
  DartItem pop() {
    final ItemEntry entry = _stack.first;
    _stack.remove(entry);
    return entry.value;
  }

  /// Peek the top stack item.
  DartItem peek() {
    final ItemEntry entry = _stack.first;
    return entry.value;
  }

  /// Size.
  int size() {
    return _stack.length;
  }

  /// Clear.
  void clear() {
    _stack.clear();
  }

  /// Stack walker, returns the stack from bottom to
  /// top as a list of Dart data items.
  /// Returns null if the stack is empty.
  List<dynamic> walk() {
    if (_stack.length == 0) return null;
    final List<dynamic> ret = new List<dynamic>();
    ItemEntry entry = _stack.last;
    ret.add(entry.value.data);
    while (entry.next != null) {
      final ItemEntry inner = entry.next;
      ret.add(inner.value.data);
      entry = inner;
    }
    return ret;
  }
}
