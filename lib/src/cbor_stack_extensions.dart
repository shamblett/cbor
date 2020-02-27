/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 27/02/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

extension ListUtilities<T> on stack.Stack<T> {
  /// Non destructive toList
  List<T> toList() {
    if (isEmpty) {
      return null;
    }
    var _list = <T>[];
    var _stack = this;
    while (_stack.isNotEmpty) {
      _list.add(_stack.pop());
    }
    return _list;
  }
}
