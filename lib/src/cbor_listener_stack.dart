/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class ListenerStack extends Listener {
  ItemStack _stack = new ItemStack();

  /// Get the stack
  ItemStack get stack => _stack;

  void onInteger(int value) {
    final DartItem item = new DartItem();
    item.data = value;
    item.type = dartTypes.dtInt;
    _append(item);
  }

  void onBytes(typed.Uint8Buffer data, int size) {}

  void onString(String str) {}

  void onArray(int size) {}

  void onArrayElement(int value) {}

  void onMap(int size) {}

  void onTag(int tag) {}

  void onSpecial(int code) {}

  void onSpecialFloat(double value) {}

  void onBool(bool state) {}

  void onNull() {}

  void onUndefined() {}

  void onError(String error) {}

  void onExtraInteger(int value, int sign) {}

  void onExtraTag(int tag) {}

  void onExtraSpecial(int tag) {}

  void onIndefinate(String text) {}

  /// Main stack append method
  void _append(DartItem item) {
    _appendImpl(item);
  }

  /// Implementation
  void _appendImpl(DartItem item) {
    if (_stack.size() == 0) {
      // Empty stack, straight add
      item.complete = true;
      _stack.push(item);
    } else {
      final DartItem entry = _stack.peek();

      /// If its complete push
      /// our item. if not complete append and check
      /// for completeness.
      if (entry.complete) {
        item.complete = true;
        _stack.push(item);
      } else {
        // TODO
      }
    }
  }
}
