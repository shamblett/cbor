/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart' as typed;

// ignore_for_file: always_specify_types
// ignore_for_file: prefer_single_quotes

class ListenerTest extends cbor.Listener {
  List<dynamic> lastValue = <dynamic>[];
  int lastTag = 0;
  int lastByteCount = 0;
  int lastSize = 0;
  int arrSize = 0;
  bool indefiniteStart = false;

  void clear() {
    lastValue.clear();
    lastTag = 0;
    lastByteCount = 0;
    lastSize = 0;
    arrSize = 0;
    indefiniteStart = false;
  }

  @override
  void onInteger(int value) {
    print("Integer $value");
    lastValue.add(value);
  }

  @override
  void onBytes(typed.Uint8Buffer data, int size) {
    print("Bytes with size: $size");
    lastValue.add(data);
    lastByteCount = size;
    print("To string - ${data.toString()}");
  }

  @override
  void onString(String str) {
    print("String $str");
    lastValue.add(str);
  }

  @override
  void onArray(int size) {
    print("Array size $size");
    lastSize = size;
  }

  void onArrayElement(int value) {
    print("No. Array elements $value");
    lastSize = value;
  }

  @override
  void onMap(int size) {
    print("Map size $size");
    lastSize = size;
  }

  @override
  void onTag(int tag) {
    print("Tag $tag");
    lastValue.add(tag);
    lastTag = tag;
  }

  @override
  void onSpecial(int code) {
    print("Code $code");
    lastValue.add(code);
  }

  @override
  void onSpecialFloat(double value) {
    print("Float Value $value");
    lastValue.add(value);
  }

  @override
  void onBool(bool state) {
    print("State $state");
    lastValue.add(state);
  }

  @override
  void onNull() {
    print("Null");
    lastValue.add(null);
  }

  @override
  void onUndefined() {
    print("Undefined");
    lastValue.add("Undefined");
  }

  @override
  void onError(String error) {
    print("Error $error");
    lastValue.add(error);
  }

  @override
  void onExtraInteger(int value, int sign) {
    print("Extra Integer value $value, Sign $sign");
    lastValue.add(value);
  }

  @override
  void onExtraTag(int tag) {
    print("Extra Tag $tag");
    lastValue.add(tag);
    lastTag = tag;
  }

  @override
  void onIndefinite(String text) {
    print("Indefinite $text");
    indefiniteStart = true;
  }
}
