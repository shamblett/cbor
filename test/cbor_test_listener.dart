/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart' as typed;

class ListenerTest extends cbor.Listener {

  List<dynamic> lastValue = new List<dynamic>();
  int lastTag = 0;
  int lastByteCount = 0;
  int lastSize = 0;
  int arrSize = 0;
  bool inArray = false;

  void clear() {
    lastValue.clear();
  }

  void onInteger(int value) {
    print("Integer $value");
    lastValue.add(value);
  }

  void onBytes(typed.Uint8Buffer data, int size) {
    print("Bytes with size: $size");
    lastValue.add(data);
    lastByteCount = size;
  }

  void onString(String str) {
    print("String $str");
    lastValue.add(str);
  }

  void onArray(int size) {
    print("Array size $size");
    lastSize = size;
  }

  void onMap(int size) {
    print("Map size $size");
    lastSize = size;
  }

  void onTag(int tag) {
    print("Tag $tag");
    lastValue.add(tag);
    lastTag = tag;
  }

  void onSpecial(int code) {
    print("Code $code");
    lastValue.add(code);
  }

  void onSpecialFloat(double value) {
    print("Float Value $value");
    lastValue.add(value);
  }

  void onBool(bool state) {
    print("State $state");
    lastValue.add(state);
  }

  void onNull() {
    print("Null");
    lastValue.add(null);
  }

  void onUndefined() {
    print("Undefined");
    lastValue.add("Undefined");
  }

  void onError(String error) {
    print("Error $error");
    lastValue.add(error);
  }

  void onExtraInteger(int value, int sign) {
    print("Extra Integer value $value, Sign $sign");
    lastValue.add(value);
  }

  void onExtraTag(int tag) {
    print("Extra Tag $tag");
    lastValue.add(tag);
    lastTag = tag;
  }

  void onExtraSpecial(int tag) {
    print("Extra Special $tag");
    lastValue.add(tag);
  }
}
