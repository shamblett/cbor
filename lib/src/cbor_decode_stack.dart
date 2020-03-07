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
  final _stack = Stack<DartItem>();

  /// The hints stack
  final hints = Stack<dataHints>();

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
  void build(ItemStack inItems) {
    if (inItems.peek() == null) {
      return;
    }

    // Create a new reversed stack for decoding
    var items = ItemStack.fromList(inItems.toList().reversed.toList());

    // Walk the stack
    built = true;
    var item;
    while (!items.isEmpty()) {
      item = items.pop();

      // Iterable, only recurse if the item is not complete
      if (item.isIterable() && !item.complete) {
        item = _processIterable(item, items);
      }

      // We should now have a complete item
      if (item.complete) {
        _stack.push(item);
      } else {
        print(
            'Decode Stack build - Error - attempt to stack incomplete item : $item');
        built = false;
      }
    }
  }

  /// Walk the built stack
  List<dynamic> walk() {
    if (!built) {
      return null;
    }
    return _stack.toList;
  }

  /// Process an iterable, list or map
  DartItem _processIterable(DartItem item, ItemStack items) {
    /// List
    if (item.type == dartTypes.dtList) {
      item.data = <dynamic>[];
      for (var i = 0; i < item.targetSize; i++) {
        var iItem = items.pop();
        if (iItem.complete) {
          item.data.add(iItem.data);
        } else if (iItem.isIterable()) {
          item.data.add(_processIterable(iItem, items).data);
        } else {
          print(
              'Decode Stack _processIterable - List item is not iterable or complete');
          return DartItem();
        }
      }
      item.complete = true;
      return item;
    } else if (item.type == dartTypes.dtMap) {
      item.data = <dynamic, dynamic>{};
      dynamic key;
      dynamic value;
      for (var i = 0; i < item.targetSize; i++) {
        var iItem = items.pop();
        if (iItem.complete) {
          // Keys cannot be iterable
          key = iItem.data;
        } else {
          print('Decode Stack _processIterable - item is incomplete map key');
          return DartItem();
        }
        iItem = items.pop();
        if (iItem.complete) {
          value = iItem.data;
        } else if (iItem.isIterable()) {
          value = _processIterable(iItem, items).data;
        } else {
          print('Decode Stack _processIterable - item is incomplete map key');
          return DartItem();
        }
        item.data[key] = value;
      }
      item.complete = true;
      return item;
    } else {
      print(
          'Decode Stack _processIterable - item is iterable but not list or map');
      return DartItem();
    }
  }
}
