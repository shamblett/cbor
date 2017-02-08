/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;
import 'dart:convert' as convertor;
import 'package:typed_data/typed_data.dart' as typed;

class ListenerTest extends cbor.Listener {

  var lastValue;
  int lastTag;
  int lastByteCount;

  void onInteger(int value) {
    print("Integer $value");
    lastValue = value;
  }

  void onBytes(typed.Uint8Buffer data, int size) {
    print("Bytes with size: $size");
    lastValue = data;
    lastByteCount = size;
  }

  void onString(typed.Uint8Buffer str) {
    final convertor.AsciiDecoder decoder = new convertor.AsciiDecoder();
    final String tmp = decoder.convert(str);
    print("String $tmp");
    lastValue = tmp;
  }

  void onArray(int size) {
    print("Array size $size");
    lastValue = size;
  }

  void onMap(int size) {
    print("Map size $size");
    lastValue = size;
  }

  void onTag(int tag) {
    print("Tag $tag");
    lastValue = tag;
    lastTag = tag;
  }

  void onSpecial(int code) {
    print("Code $code");
    lastValue = code;
  }

  void onBool(bool state) {
    print("State $state");
    lastValue = state;
  }

  void onNull() {
    print("Null");
    lastValue = null;
  }

  void onUndefined() {
    print("Undefined");
    lastValue = "Undefined";
  }

  void onError(String error) {
    print("Error $error");
    lastValue = error;
  }

  void onExtraInteger(int value, int sign) {
    print("Extra Integer value $value, Sign $sign");
    if (sign == -1) {
      lastValue = -1 - value;
    } else {
      lastValue = value;
    }
  }

  void onExtraTag(int tag) {
    print("Extra Tag $tag");
    lastValue = tag;
    lastTag = tag;
  }

  void onExtraSpecial(int tag) {
    print("Extra Special $tag");
    lastValue = tag;
  }
}
