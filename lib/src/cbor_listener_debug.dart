/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class ListenerDebug extends Listener {
  void onInteger(int value) {
    print("Integer $value");
  }

  void onBytes(typed.Uint8Buffer data, int size) {
    print("Bytes with size: $size");
  }

  void onString(String str) {
    print("String $str");
  }

  void onArray(int size) {
    print("Array size $size");
  }

  void onMap(int size) {
    print("Map size $size");
  }

  void onTag(int tag) {
    print("Tag $tag)");
  }

  void onSpecial(int code) {
    print("Code $code");
  }

  void onSpecialFloat(double value) {
    print("Float Value $value");
  }

  void onBool(bool state) {
    print("State $state");
  }

  void onNull() {
    print("Null");
  }

  void onUndefined() {
    print("Undefined");
  }

  void onError(String error) {
    print("Error $error");
  }

  void onExtraInteger(int value, int sign) {
    print("Extra Integer value $value, Sign $sign");
  }

  void onExtraTag(int tag) {
    print("Extra Tag $tag");
  }

  void onExtraSpecial(int tag) {
    print("Extra Special $tag");
  }
}
