/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class OutputStatic extends Output {
  typed.Uint8Buffer _buffer;
  int _capacity;
  int _offset;

  outputStatic(int capacity) {
    this._capacity = capacity;
    this._buffer = new typed.Uint8Buffer(capacity);
    this._offset = 0;
  }

  typed.Uint8Buffer getData() {
    return _buffer;
  }

  int getSize() {
    return _offset;
  }

  void putByte(int value) {
    if (_offset < _capacity) {
      _buffer[_offset++] = value;
    } else {
      print(
          "OutputStatic::putByte buffer overflow error offset is ${_offset}, capacity is ${_capacity}");
    }
  }

  void putBytes(typed.Uint8Buffer data, int size) {
    if (_offset + size - 1 < _capacity) {
      _buffer.add(data);
      _offset += size;
    } else {
      print(
          "OutputStatic::puBytes buffer overflow error offset is ${_offset}, capacity is ${_capacity} size is ${size}");
    }
  }
}
