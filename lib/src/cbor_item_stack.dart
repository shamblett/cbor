/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Stack helper class
class Stack<T> {
  final ListQueue<T> _list = ListQueue<T>();

  /// Check if the stack is empty.
  bool get isEmpty => _list.isEmpty;

  /// Check if the stack is not empty.
  bool get isNotEmpty => _list.isNotEmpty;

  /// Push an element on to the top of the stack.
  void push(T e) {
    _list.addLast(e);
  }

  /// Get the top of the stack and delete it(pop).
  T pop() {
    final T res = _list.last;
    _list.removeLast();
    return res;
  }

  /// Get the top of the stack without deleting it(peek).
  T top() => _list.last;

  /// Length
  int get length => _list.length;

  /// Clear
  void clear() => _list.clear();

  /// toList
  List<T> toList() => _list.toList();
}

/// The decoded Dart item stack class.
class ItemStack {
  final Stack<DartItem> _stack = Stack<DartItem>();

  /// Push an item.
  void push(DartItem item) {
    _stack.push(item);
  }

  /// Pop an item from the stack top.
  DartItem pop() => _stack.pop();

  /// Peek the top stack item.
  DartItem peek() => _stack.top();

  /// Size.
  int size() => _stack.length;

  /// Clear.
  void clear() => _stack.clear();

  /// Stack walker, returns the stack from bottom to
  /// top as a list of Dart types.
  /// Returns null if the stack is empty.
  List<dynamic> walk() {
    if (_stack.isEmpty) {
      return null;
    }
    return _stack
        .toList()
        .where((DartItem e) => !e.ignore)
        .map((DartItem e) => e.data)
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
        .toList()
        .where((DartItem e) => !e.ignore)
        .map((DartItem e) => e.hint)
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
        .toList()
        .where((DartItem e) => e.hint == dataHints.error)
        .map((DartItem e) => e.data)
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
