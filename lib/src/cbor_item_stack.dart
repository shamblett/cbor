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
  /// top as a list of Dart types.
  /// Returns null if the stack is empty.
  List<dynamic> walk() {
    if (_stack.length == 0) return null;
    final List<dynamic> ret = new List<dynamic>();
    final List<ItemEntry> stackList = _stack.toList();
    stackList.reversed.forEach((item) {
      if (!item.value.ignore) {
        ret.add(item.value.data);
      }
    });
    return ret;
  }

  /// Check if any error entries are present in the stack.
  /// Returns a list of error strings if any are found, null
  /// if none are found.
  List<String> errors() {
    final List<String> text = new List<String>();
    if (_stack.length == 0) return null;
    ItemEntry entry = _stack.last;
    if (entry.value.hint == dataHints.error) {
      text.add(entry.value.data);
    }
    while (entry.next != null) {
      final ItemEntry inner = entry.next;
      if (inner.value.hint == dataHints.error) {
        text.add(entry.value.data);
      }
      entry = inner;
    }
    return text;
  }

  /// Quick check if the stack contains any errors.
  bool hasErrors() {
    if (errors() == null) {
      return false;
    } else {
      return true;
    }
  }
}
