/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class OutputDynamic extends Output {
  typed.Uint8Buffer _buffer;

  OutputDynamic() {
    this._buffer = new typed.Uint8Buffer();
  }

  typed.Uint8Buffer getData() {
    return _buffer;
  }

  int size() {
    return _buffer.length;
  }

  void putByte(int value) {
    _buffer.add(value);
  }

  void putBytes(typed.Uint8Buffer data) {
    _buffer.addAll(data);
  }
}
