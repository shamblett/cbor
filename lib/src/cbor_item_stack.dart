/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The decoded Dart item stack class.
class ItemStack {
  /// Construction
  ItemStack();

  /// From list
  ItemStack.fromList(List<DartItem> items) {
    items.forEach(_stack.push);
  }

  /// The stack
  var _stack = Stack<DartItem>();

  /// is Empty
  bool isEmpty() => _stack.isEmpty;

  /// Length
  int get length => _stack.length;

  /// Push an item.
  void push(DartItem item) {
    _stack.push(item);
  }

  /// Pop an item from the stack top.
  DartItem pop() => _stack.pop();

  /// Pop an item from the stack bottom.
  DartItem popBottom() => _stack.popBottom();

  /// Peek the top stack item.
  DartItem? peek() => _stack.top();

  /// Peek the bottom stack item.
  DartItem peekBottom() => _stack.bottom();

  /// Walk the stack
  List<DartItem> walk() => _stack.toList;

  /// Clear the stack;
  void clear() {
    _stack = Stack<DartItem>();
  }

  /// toList
  List<DartItem> toList() => _stack.toList;

  /// Check if any error entries are present in the stack.
  /// Returns a list of error strings if any are found, null
  /// if none are found.
  List<String>? errors() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack.toList
        .where((e) => e.hint == dataHints.error)
        .map((e) => e.data)
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
