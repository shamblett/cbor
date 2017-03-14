/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// What we are waiting for next, if anything.
enum whatsNext { aPositiveBignum, aNegativeBignum, nothing }

class ListenerStack extends Listener {
  ItemStack _stack = new ItemStack();

  /// Get the stack
  ItemStack get stack => _stack;

  /// Used to indicate what the
  /// next decoded item should be.
  whatsNext _next = whatsNext.nothing;

  void onInteger(int value) {
    // Do not add nulls
    if (value == null) return;
    final DartItem item = new DartItem();
    item.data = value;
    item.type = dartTypes.dtInt;
    _append(item);
  }

  void onBytes(typed.Uint8Buffer data, int size) {
    // Check if we are expecting something, ie whats next
    switch (_next) {
      case whatsNext.aPositiveBignum:
      // Convert to a positive integer and append
        final int value = bignumToInt(data, "+");
        onInteger(value);
        _next = whatsNext.nothing;
        break;
      case whatsNext.aNegativeBignum:
        int value = bignumToInt(data, "-");
        value = -1 + value;
        onInteger(value.abs());
        _next = whatsNext.nothing;
        break;
      case whatsNext.nothing:
        break;
    }
  }

  void onString(String str) {}

  void onArray(int size) {}

  void onArrayElement(int value) {}

  void onMap(int size) {}

  void onTag(int tag) {
    // Switch on the tag type
    switch (tag) {
      case 0: // Date/Time string
        break;
      case 1: // Date/Time epoch
        break;
      case 2: // Positive bignum
        _next = whatsNext.aPositiveBignum;
        break;
      case 3: // Negative bignum
        _next = whatsNext.aNegativeBignum;
        break;
      default:
        print("Unimplemented tag type $tag");
    }
  }

  void onSpecial(int code) {}

  void onSpecialFloat(double value) {
    // Do not add nulls
    if (value == null) return;
    final DartItem item = new DartItem();
    item.data = value;
    item.type = dartTypes.dtDouble;
    _append(item);
  }

  void onBool(bool state) {}

  void onNull() {}

  void onUndefined() {}

  void onError(String error) {}

  void onExtraInteger(int value, int sign) {
    onInteger(value);
  }

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
