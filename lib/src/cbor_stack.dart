/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/03/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Base stack class
class Stack<T> {
  final ListQueue<T> _list = ListQueue();

  /// Check if the stack is empty.
  bool get isEmpty => _list.isEmpty;

  /// Check if the stack is not empty.
  bool get isNotEmpty => _list.isNotEmpty;

  /// Length
  int get length => _list.length;

  /// toList
  List<T> get toList => _list.toList();

  /// Push element in top of the stack.
  void push(T e) {
    _list.addLast(e);
  }

  /// Get the top of the stack and delete it.
  T pop() {
    var res = _list.last;
    _list.removeLast();
    return res;
  }

  /// Get the bottom of the stack and delete it.
  T popBottom() {
    var res = _list.first;
    _list.removeFirst();
    return res;
  }

  /// Get the top of the stack without deleting it.
  T top() {
    return _list.last;
  }

  /// Get the bottom of the stack without deleting it.
  T bottom() {
    return _list.first;
  }
}
