/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The Input class provides data access primitives to the underlying
/// UTF-8 data buffer supplied.

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
    final int value = (_data[_offset] << 8 | _data[_offset + 1]);
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
    // Check for known patterns/anomalies and return
    // the correct values otherwise use the algorithm below.

    // Prefilter
    if (val == 1) return 5.960464477539063e-8;
    final double ret = getHalfPrecisionDouble(val);
    // Post filter
    if (ret == 65536.0) return double.INFINITY;
    if (ret == -65536.0) return -(double.INFINITY);
    if (ret == 98304.0) return double.NAN;
    return ret;
  }

  double getSingleFloat(typed.Uint8Buffer buff) {
    final ByteData bdata = new ByteData.view(buff.buffer);
    return bdata.getFloat32(0);
  }

  double getDoubleFloat(typed.Uint8Buffer buff) {
    final ByteData bdata = new ByteData.view(buff.buffer);
    return bdata.getFloat64(0);
  }

  /// Reset the offset
  void reset() {
    _offset = 0;
  }
}
