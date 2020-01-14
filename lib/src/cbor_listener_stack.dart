/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

// ignore_for_file: public_member_api_docs
// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations

/// What we are waiting for next, if anything.
enum whatsNext {
  aDateTimeString,
  aDateTimeEpoch,
  aDecimalFraction,
  aBigFloat,
  unassigned,
  aPositiveBignum,
  aNegativeBignum,
  aMultipleB64Url,
  aMultipleB64,
  aMultipleB16,
  encodedCBOR,
  aStringUri,
  aStringB64Url,
  aStringB64,
  aRegExp,
  aMIMEMessage,
  aSelfDescribeCBOR,
  nothing
}

/// The stack based listener class, produces a stack of DartItems
/// from the decoder output.
class ListenerStack extends Listener {
  final ItemStack _stack = ItemStack();

  /// Get the stack
  ItemStack get stack => _stack;

  /// Used to indicate what the
  /// next decoded item should be.
  whatsNext _next = whatsNext.nothing;

  /// Indefinite stack.
  /// A list of indefinite items, most recent at the end.
  /// Can only be string, bytes, list or map.
  final List<String> _indefiniteStack = <String>[];

  /// Indefinite bytes buffer assembler.
  final typed.Uint8Buffer _byteAssembly = typed.Uint8Buffer();

  /// Indefinite String buffer assembler.
  String _stringAssembly;

  @override
  void onInteger(int value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = value;
    item.type = dartTypes.dtInt;
    item.complete = true;
    if (_next == whatsNext.aDateTimeEpoch) {
      item.hint = dataHints.dateTimeEpoch;
      _next = whatsNext.nothing;
    }
    _append(item);
  }

  void onBigInteger(BigInt value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = value;
    item.type = dartTypes.dtBigInt;
    item.complete = true;
    if (_next == whatsNext.aDateTimeEpoch) {
      item.hint = dataHints.dateTimeEpoch;
      _next = whatsNext.nothing;
    }
    _append(item);
  }

  @override
  void onBytes(typed.Uint8Buffer data, int size) {
    // Check if we are expecting something, ie whats next
    switch (_next) {
      case whatsNext.aPositiveBignum:
        // Convert to a positive integer and append
        final BigInt value = bignumToBigInt(data, '+');
        onBigInteger(value);
        break;
      case whatsNext.aNegativeBignum:
        BigInt value = bignumToBigInt(data, '-');
        value = BigInt.from(-1) + value;
        onBigInteger(value.abs());
        break;
      case whatsNext.aMultipleB64Url:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base64Url;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aMultipleB64:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base64;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aMultipleB16:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.base16;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.encodedCBOR:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.encodedCBOR;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.aSelfDescribeCBOR:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.hint = dataHints.selfDescCBOR;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.unassigned:
        if (data != null) {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.complete = true;
          _append(item);
        }
        break;
      case whatsNext.nothing:
      default:
        if (data == null) {
          return;
        }
        if (_waitingIndefBytes()) {
          _byteAssembly.addAll(data);
        } else {
          final DartItem item = DartItem();
          item.data = data;
          item.type = dartTypes.dtBuffer;
          item.complete = true;
          _append(item);
        }
    }
    _next = whatsNext.nothing;
  }

  @override
  void onString(String str) {
    if (str == null) {
      return;
    }
    if (_waitingIndefString()) {
      _stringAssembly += str;
    } else {
      final DartItem item = DartItem();
      item.data = str;
      item.type = dartTypes.dtString;
      switch (_next) {
        case whatsNext.aDateTimeString:
          item.hint = dataHints.dateTimeString;
          break;
        case whatsNext.aStringUri:
          item.hint = dataHints.uri;
          break;
        case whatsNext.aStringB64Url:
          item.hint = dataHints.base64Url;
          break;
        case whatsNext.aStringB64:
          item.hint = dataHints.base64;
          break;
        case whatsNext.aRegExp:
          item.hint = dataHints.regex;
          break;
        case whatsNext.aMIMEMessage:
          item.hint = dataHints.mime;
          break;
        default:
          break;
      }
      _next = whatsNext.nothing;
      item.complete = true;
      _append(item);
    }
  }

  @override
  void onArray(int size) {
    final DartItem item = DartItem();
    item.type = dartTypes.dtList;
    item.data = <dynamic>[];
    item.targetSize = size;
    if (size == 0) {
      item.complete = true;
    }
    _append(item);
  }

  @override
  void onMap(int size) {
    final DartItem item = DartItem();
    item.type = dartTypes.dtMap;
    item.data = <dynamic, dynamic>{};
    item.targetSize = size;
    item.awaitingMapKey = true;
    if (size == 0) {
      item.complete = true;
    }
    _append(item);
  }

  @override
  void onTag(int tag) {
    // Switch on the tag type
    switch (tag) {
      case 0: // Date time string
        _next = whatsNext.aDateTimeString;
        break;
      case 1: // Date/Time epoch
        _next = whatsNext.aDateTimeEpoch;
        break;
      case 2: // Positive bignum
        _next = whatsNext.aPositiveBignum;
        break;
      case 3: // Negative bignum
        _next = whatsNext.aNegativeBignum;
        break;
      case 4: // Decimal fraction
        _next = whatsNext.aDecimalFraction;
        break;
      case 5: // Bigfloat
        _next = whatsNext.aBigFloat;
        break;
      case 21: // B64 URL
        _next = whatsNext.aMultipleB64Url;
        break;
      case 22: // B64
        _next = whatsNext.aMultipleB64;
        break;
      case 23: // B16
        _next = whatsNext.aMultipleB16;
        break;
      case 24: // Encoded CBOR item
        _next = whatsNext.encodedCBOR;
        break;
      case 32: // URI
        _next = whatsNext.aStringUri;
        break;
      case 33: // String B64 URL
        _next = whatsNext.aStringB64Url;
        break;
      case 34: // String B64
        _next = whatsNext.aStringB64;
        break;
      case 35: // Regular Expression
        _next = whatsNext.aRegExp;
        break;
      case 36: // MIME message
        _next = whatsNext.aMIMEMessage;
        break;
      case 55799: // Self describe CBOR sequence
        _next = whatsNext.aSelfDescribeCBOR;
        break;
      default: // Unassigned values
        _next = whatsNext.unassigned;
    }
  }

  @override
  void onSpecial(int code) {
    if (code == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = code;
    item.type = dartTypes.dtInt;
    item.complete = true;
    _append(item);
  }

  @override
  void onSpecialFloat(double value) {
    // Do not add nulls
    if (value == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = value;
    item.type = dartTypes.dtDouble;
    item.complete = true;
    _append(item);
  }

  @override
  void onBool(bool state) {
    // Do not add nulls
    if (state == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = state;
    item.type = dartTypes.dtBool;
    item.complete = true;
    _append(item);
  }

  @override
  void onNull() {
    final DartItem item = DartItem();
    item.type = dartTypes.dtNull;
    item.complete = true;
    _append(item);
  }

  @override
  void onUndefined() {
    final DartItem item = DartItem();
    item.type = dartTypes.dtUndefined;
    item.complete = true;
    _append(item);
  }

  @override
  void onError(String error) {
    if (error == null) {
      return;
    }
    final DartItem item = DartItem();
    item.data = error;
    item.type = dartTypes.dtString;
    item.hint = dataHints.error;
    item.complete = true;
    _append(item);
  }

  @override
  void onExtraInteger(int value, int sign) {
    // Sign adjustment is done by the decoder so
    // we can ignore it here
    onInteger(value);
  }

  @override
  void onExtraTag(int tag) {
    // Not yet implemented
  }

  @override
  void onIndefinite(String text) {
    // Process depending on indefinite type.
    switch (text) {
      case indefBytes:
        _indefiniteStack.add(text);
        _byteAssembly.clear();
        break;
      case indefString:
        _indefiniteStack.add(text);
        _stringAssembly = '';
        break;
      case indefMap:
        _indefiniteStack.add(text);
        onMap(indefiniteMaxSize);
        break;
      case indefArray:
        _indefiniteStack.add(text);
        onArray(indefiniteMaxSize);
        break;
      case indefStop:
        // Get the top of the indefinite stack and switch on it.
        if (_indefiniteStack.isEmpty) {
          onError('Unbalanced indefinite break');
          break;
        }
        final String top = _indefiniteStack.removeLast();
        switch (top) {
          case indefBytes:
            onBytes(_byteAssembly, _byteAssembly.length);
            break;
          case indefString:
            onString(_stringAssembly);
            break;
          case indefMap:
          case indefArray:
            // Complete the stack top, pop and append
            _stack.peek().targetSize = _stack.peek().data.length;
            _stack.peek().complete = true;
            _append(_stack.pop());
            break;
          default:
            onError('Unknown indefinite type on stop');
        }
        break;
      default:
        onError('Unknown indefinite type on start');
    }
  }

  /// Main stack append method.
  void _append(DartItem item) {
    _appendImpl(item);
  }

  /// Append implementation.
  void _appendImpl(DartItem item) {
    if (_stack.size() == 0) {
      // Empty stack, straight add
      _stack.push(item);
    } else {
      final DartItem entry = _stack.peek();

      /// If its complete push
      /// the item. if not complete append and check
      /// for completeness.
      if (entry.complete) {
        _stack.push(item);
      } else {
        // List or Map
        if (entry.type == dartTypes.dtList) {
          if (item.isIncompleteList()) {
            _stack.push(item);
          } else if (item.isIncompleteMap()) {
            _addItemToEntry(item, entry);
            _stack.push(item);
          } else {
            _addItemToEntry(item, entry);
          }
        } else if (entry.type == dartTypes.dtMap) {
          // Check if we are expecting a key or a value
          if (entry.awaitingMapKey) {
            // Create the map entry with the key, set we
            // are now waiting for a value.
            entry.data.addAll(<dynamic, dynamic>{item.data: null});
            entry.lastMapKey = item.data;
            entry.awaitingMapKey = false;
            entry.awaitingMapValue = true;
          } else if (entry.awaitingMapValue) {
            // If the item is a list or a map just push it if it
            // is not complete,
            // if not then reset awaiting map value.
            // Either way update the entry with the value.
            if (item.isIncompleteList() || item.isIncompleteMap()) {
              _stack.push(item);
            } else {
              entry.awaitingMapValue = false;
            }
            entry.data[entry.lastMapKey] = item.data;

            // Check for completeness
            if (entry.data.length == entry.targetSize) {
              entry.complete = true;
              // Item can be ignored.
              item.ignore = true;
              // Recurse for nested maps
              final DartItem item1 = _stack.pop();
              _appendImpl(item1);
            } else {
              // If we are still awiating a value(netsed list
              // or map) then don't expect a key.
              if (!entry.awaitingMapValue) {
                entry.awaitingMapKey = true;
              }
            }
          }
        } else {
          onError('Incomplete stack item is not list or map');
        }
      }
    }
  }

  /// Helper functions.

  /// Waiting for indefinite bytes.
  bool _waitingIndefBytes() {
    if (_indefiniteStack.isNotEmpty) {
      if (_indefiniteStack.last == indefBytes) {
        return true;
      }
    }
    return false;
  }

  /// Waiting for indefinite string.
  bool _waitingIndefString() {
    if (_indefiniteStack.isNotEmpty) {
      if (_indefiniteStack.last == indefString) {
        return true;
      }
    }
    return false;
  }

  void _addItemToEntry(DartItem item, DartItem entry) {
    entry.data.add(item.data);
    // If the entry is a list and the item is a map we can't
    // test against the target size until the map is complete
    if (entry.type == dartTypes.dtList) {
      print('KKK');
    } else {
      if (entry.data.length == entry.targetSize) {
        entry.complete = true;
        // Item can be ignored.
        item.ignore = true;
        // Recurse for nested lists
        final DartItem item1 = _stack.pop();
        _appendImpl(item1);
      }
    }
  }
}
