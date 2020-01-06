/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

// ignore_for_file: public_member_api_docs
// ignore_for_file: avoid_print
// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations

/// A simple debug listener.
class ListenerDebug extends Listener {
  @override
  void onInteger(int value) {
    print('Integer $value');
  }

  void banner(String text) {
    print(text);
  }

  @override
  void onBytes(typed.Uint8Buffer data, int size) {
    print('Bytes with size: $size');
  }

  @override
  void onString(String str) {
    print('String $str');
  }

  @override
  void onArray(int size) {
    print('Array size $size');
  }

  void onArrayElement(int value) {
    print('Array Element $value');
  }

  @override
  void onMap(int size) {
    print('Map size $size');
  }

  @override
  void onTag(int tag) {
    print('Tag $tag');
  }

  @override
  void onSpecial(int code) {
    print('Code $code');
  }

  @override
  void onSpecialFloat(double value) {
    print('Float Value $value');
  }

  @override
  void onBool(bool state) {
    print('State $state');
  }

  @override
  void onNull() {
    print('Null');
  }

  @override
  void onUndefined() {
    print('Undefined');
  }

  @override
  void onError(String error) {
    print('Error $error');
  }

  @override
  void onExtraInteger(int value, int sign) {
    print('Extra Integer value $value, Sign $sign');
  }

  @override
  void onExtraTag(int tag) {
    print('Extra Tag $tag');
  }

  @override
  void onIndefinite(String text) {
    print('Indefinate Item $text');
  }
}
