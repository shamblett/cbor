/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

/// A Dart item linked list entry for use by the stack
class ItemEntry<DartItem> extends LinkedListEntry<ItemEntry<DartItem>> {
  /// Construction
  ItemEntry(this.value);

  /// The item
  DartItem value;

  @override
  String toString() => '${super.toString()} : value.toString()';
}

/// The decoded Dart item stack class.
class ItemStack {
  /// The stack
  final List<ItemEntry<DartItem>> _stack = <ItemEntry<DartItem>>[];

  /// Push an item.
  void push(DartItem item) {
    final ItemEntry<DartItem> entry = ItemEntry<DartItem>(item);
    _stack.add(entry);
  }

  /// Pop an item from the stack top.
  DartItem pop() {
    final ItemEntry<DartItem> entry = _stack.removeLast();
    return entry.value;
  }

  /// Peek the top stack item.
  DartItem peek() {
    final ItemEntry<DartItem> entry = _stack.last;
    return entry.value;
  }

  /// Size.
  int size() => _stack.length;

  /// Clear.
  void clear() {
    _stack.clear();
  }

  /// Stack walker, returns the stack from bottom to
  /// top as a list of Dart types.
  /// Returns null if the stack is empty.
  List<dynamic> walk() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack
        // ignore: always_specify_types
        .where((e) => !e.value.ignore)
        // ignore: always_specify_types
        .map((e) => e.value.data)
        .toList();
  }

  /// Gets item hints. Returns item hints for stack items.
  /// If used with the walk stack the returned list can
  /// be used on a per index basis.
  List<dataHints> hints() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack
        // ignore: always_specify_types
        .where((e) => !e.value.ignore)
        // ignore: always_specify_types
        .map((e) => e.value.hint)
        .toList()
        .cast<dataHints>();
  }

  /// Check if any error entries are present in the stack.
  /// Returns a list of error strings if any are found, null
  /// if none are found.
  List<String> errors() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack
        // ignore: always_specify_types
        .where((e) => e.value.hint == dataHints.error)
        // ignore: always_specify_types
        .map((e) => e.value.data)
        .toList()
        .cast<String>();
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
