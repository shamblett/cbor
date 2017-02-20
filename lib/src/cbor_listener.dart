/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Listener base class, all listener implementations must at least
/// implement these methods to interface to the decoder.

abstract class Listener {
  void onInteger(int value);

  void onBytes(typed.Uint8Buffer data, int size);

  void onString(String str);

  void onArray(int size);

  void onArrayElement(int value);

  void onMap(int size);

  void onTag(int tag);

  void onSpecial(int code);

  void onSpecialFloat(double value);

  void onBool(bool state);

  void onNull();

  void onUndefined();

  void onError(String error);

  void onExtraInteger(int value, int sign);

  void onExtraTag(int tag);

  void onExtraSpecial(int tag);

  void onIndefinate(String text);
}
