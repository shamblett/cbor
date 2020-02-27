/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The decoded Dart item stack class.
class ItemStack {
  /// The stack
  var _stack = stack.Stack<DartItem>();

  /// Push an item.
  void push(DartItem item) {
    _stack.push(item);
  }

  /// Pop an item from the stack top.
  DartItem pop() => _stack.pop();

  /// Peek the top stack item.
  DartItem peek() => _stack.top();

  /// Walk the stack
  List<DartItem> walk() => _stack.walk();

  /// Clear the stack;
  void clear() {
    _stack = stack.Stack<DartItem>();
  }
}
