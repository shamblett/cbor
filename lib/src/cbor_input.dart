/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

class Input {
  typed.Uint8Buffer _data;
  int _offset;

  Input(typed.Uint8Buffer data, int size) {
    this._data = data;
    this._offset = 0;
  }

  bool hasBytes(int count) {
    return _data.lengthInBytes - _offset >= count;
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
    final int value = (_data[_offset] << 24) |
    (_data[_offset + 1] << 16) |
    (_data[_offset + 2] << 8) |
    (_data[_offset + 3]);
    _offset += 4;
    return value;
  }

  int getLong() {
    final int value = (_data[_offset] << 56) |
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

  typed.Uint8Buffer getBytes(int count) {
    final List<int> tmp = _data.sublist(_offset, _offset + count);
    final typed.Uint8Buffer buff = new typed.Uint8Buffer();
    buff.addAll(tmp);
    _offset += count;
    return buff;
  }

  double getHalfFloat(int val) {
    int t1;
    int t2;
    int t3;
    t1 = val & 0x7fff; // Non-sign bits
    t2 = val & 0x8000; // Sign bit
    t3 = val & 0x7c00; // Exponent
    t1 <<= 13; // Align mantissa on MSB
    t2 <<= 16; // Shift sign bit into position
    t1 += 0x38000000; // Adjust bias
    t1 = (t3 == 0 ? 0 : t1); // Denormalise as zero
    t1 |= t2; // re-insert sign bit
    final List<int> tmp = new List<int>();
    tmp.add((t1 >> 24) & 0xff);
    tmp.add((t1 >> 16) & 0xff);
    tmp.add((t1 >> 8) & 0xff);
    tmp.add(t1 & 0xff);
    final typed.Uint8Buffer buff = new typed.Uint8Buffer();
    buff.addAll(tmp);
    final ByteData bdata = new ByteData.view(buff.buffer);
    return bdata.getFloat32(0);
  }

  double getSingleFloat(typed.Uint8Buffer buff) {
    final ByteData bdata = new ByteData.view(buff.buffer);
    return bdata.getFloat32(0);
  }

  double getDoubleFloat(typed.Uint8Buffer buff) {
    final ByteData bdata = new ByteData.view(buff.buffer);
    return bdata.getFloat64(0);
  }
}
