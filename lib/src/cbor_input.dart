/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class input {
  typed.Uint8Buffer _data;
  int _size;
  int _offset;

  input(typed.Uint8Buffer data, int size) {
    this._data = data;
    this._size = size;
    this._offset = 0;
  }

  bool hasBytes(int count) {
    return _size - _offset >= count;
  }

  int getByte() {
    return _data[_offset++];
  }

  int getShort() {
    int value = (_data[_offset] << 8 | _data[_offset + 1]);
    _offset += 2;
    return value;
  }

  int getInt() {
    int value = (_data[_offset] << 24) |
    (_data[_offset + 1] << 16) |
    (_data[_offset + 2] << 8) |
    (_data[_offset + 3]);
    _offset += 4;
    return value;
  }

  int getLong() {
    int value = (_data[_offset] << 56) |
    (_data[_offset + 1] << 48) |
    (_data[_offset + 2] << 40) |
    (_data[_offset + 3] << 32) |
    (_data[_offset + 4] << 24) |
    (_data[_offset + 5] << 16) |
    (_data[_offset + 6] << 8) |
    (_data[_offset + 7]);
    _offset += 8;
    return value;
  }

  void getBytes(typed.Uint8Buffer to, int count) {
    _offset += count;
    to = _data;
  }
}
