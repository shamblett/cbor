/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 27/02/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The stack of dart items assembled from the listener stack
class DecodeStack {
  /// The stack
  final _stack = stack.Stack<DartItem>();

  /// The hints stack
  final hints = stack.Stack<dataHints>();

  /// Stack is built
  bool built = false;

  /// Stack has errors
  bool errors = false;

  /// Push an item.
  void push(DartItem item) {
    _stack.push(item);
  }

  /// Pop an item from the stack top.
  DartItem pop() => _stack.pop();

  /// Peek the top stack item.
  DartItem peek() => _stack.top();

  /// Build the decoded stack from the listener stack
  void build(ItemStack items) {
    built = true;
  }

  /// Walk the built stack
  List<dynamic> walk() {
    if (!built) {
      return null;
    }
    return [];
  }
}
