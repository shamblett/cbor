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

  /// Push an item.
  void push(DartItem item) {
    _stack.push(item);
  }

  /// Pop an item from the stack top.
  DartItem pop() => _stack.pop();

  /// Peek the top stack item.
  DartItem peek() => _stack.top();

  /// Walk the stack
  List<DartItem> walk() => _stack.toList;

  /// Clear the stack;
  void clear() {
    _stack = Stack<DartItem>();
  }

  /// toList
  List<DartItem> toList() => _stack.toList;
}
