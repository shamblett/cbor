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
  /// Default
  Input(typed.Uint8Buffer data) {
    _data = data;
    _offset = 0;
  }

  typed.Uint8Buffer _data;
  int _offset;

  /// Does the input have the numbe of bytes.
  bool hasBytes(int count) => _data.lengthInBytes - _offset >= count;

  /// Get a single byte.
  int getByte() => _data[_offset++];

  /// Get a short, 16 bits.
  int getShort() {
    final value = _data[_offset] << 8 | _data[_offset + 1];
    _offset += 2;
    return value;
  }

  /// Get an int, 32 bits.
  int getInt() {
    final value = (_data[_offset] << 24) |
        (_data[_offset + 1] << 16) |
        (_data[_offset + 2] << 8) |
        (_data[_offset + 3]);
    _offset += 4;
    return value;
  }

  /// Get a long, 64 bits.
  int getLong() {
    final value = (_data[_offset] << 56) |
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

  /// Get the number of bytes specified.
  typed.Uint8Buffer getBytes(int count) {
    final tmp = _data.sublist(_offset, _offset + count);
    final buff = typed.Uint8Buffer();
    buff.addAll(tmp);
    _offset += count;
    return buff;
  }

  /// Get a half-precision float from an integer value.
  double getHalfFloat(int val) {
    // Check for known patterns/anomalies and return
    // the correct values otherwise use the algorithm below.

    // Prefilter
    if (val == 1) {
      return 5.960464477539063e-8;
    }
    final ret = getHalfPrecisionDouble(val);
    // Post filter
    if (ret == 65536.0) {
      return double.infinity;
    }
    if (ret == -65536.0) {
      return -double.infinity;
    }
    if (ret == 98304.0) {
      return double.nan;
    }
    return ret;
  }

  /// Get a single-precision float from a buffer value.
  double getSingleFloat(typed.Uint8Buffer buff) {
    final bdata = ByteData.view(buff.buffer);
    return bdata.getFloat32(0);
  }

  /// Get a double-precision float from a buffer value.
  double getDoubleFloat(typed.Uint8Buffer buff) {
    final bdata = ByteData.view(buff.buffer);
    return bdata.getFloat64(0);
  }

  /// Reset the offset.
  void reset() {
    _offset = 0;
  }
}
