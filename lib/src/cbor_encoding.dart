/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* Primitives encoding
* ============================================================================
*/

const int uint8Max = 2 ^ 8 - 1;
const int uint16Max = 2 ^ 16 - 1;
const int uint32Max = 2 ^ 32 - 1;
const int uint64Max = 2 ^ 64 - 1;

int cborEncodeUint8(int value, ByteData buffer, int bufferSize,
    [int offset = 0]) {
  assert(value >= 0 && value <= uint8Max);
  if (value <= 23) {
    if (bufferSize >= 1) {
      buffer.setUint8(0, value + offset);
      return 1;
    }
  } else {
    if (bufferSize >= 2) {
      buffer.setUint8(0, 0x18 + offset);
      buffer.setUint8(1, value);
      return 2;
    }
  }
  return 0;
}

int cborEncodeUint16(int value, ByteData buffer, int bufferSize,
    [int offset = 0]) {
  assert(value >= 0 && value <= uint16Max);
  if (bufferSize >= 3) {
    buffer.setUint8(0, 0x19 + offset);
    buffer.setUint16(1, value);
    return 3;
  } else {
    return 0;
  }
}

int cborEncodeUint32(int value, ByteData buffer, int bufferSize,
    [int offset = 0]) {
  assert(value >= 0 && value <= uint32Max);
  if (bufferSize >= 5) {
    buffer.setUint8(0, 0x1A + offset);
    buffer.setUint32(1, value);
    return 5;
  } else {
    return 0;
  }
}

int cborEncodeUint64(int value, ByteData buffer, int bufferSize,
    [int offset = 0]) {
  assert(value >= 0 && value <= uint64Max);
  if (bufferSize >= 9) {
    buffer.setUint8(0, 0x1B + offset);
    buffer.setUint64(1, value);
    return 9;
  } else {
    return 0;
  }
}

int cborEncodeUint(int value, ByteData buffer, int bufferSize,
    [int offset = 0]) {
  if (value <= uint16Max)
    if (value <= uint8Max)
      return cborEncodeUint8(value, buffer, bufferSize, offset);
    else
      return cborEncodeUint16(value, buffer, bufferSize, offset);
  else if (value <= uint32Max)
    return cborEncodeUint32(value, buffer, bufferSize, offset);
  else
    return cborEncodeUint64(value, buffer, bufferSize, offset);
}

int cborEncodeNegint8(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint8(value, buffer, bufferSize, 0x20);
}

int cborEncodeNegint16(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint16(value, buffer, bufferSize, 0x20);
}

int cborEncodeNegint32(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint32(value, buffer, bufferSize, 0x20);
}

int cborEncodeNegint64(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint64(value, buffer, bufferSize, 0x20);
}

int cborEncodeNegint(int value, ByteData buffer, int bufferSize) {
  if (value <= uint16Max)
    if (value <= uint8Max)
      return cborEncodeNegint8(value, buffer, bufferSize);
    else
      return cborEncodeNegint16(value, buffer, bufferSize);
  else if (value <= uint32Max)
    return cborEncodeNegint32(value, buffer, bufferSize);
  else
    return cborEncodeNegint64(value, buffer, bufferSize);
}

int cborEncodeBytestringStart(int length, ByteData buffer, int bufferSize) {
  return cborEncodeUint8(length, buffer, bufferSize, 0x40);
}

int _cborEncodeByte(int value, ByteData buffer, int bufferSize) {
  if (bufferSize >= 1) {
    buffer.setUint8(0, value);
    return 1;
  } else
    return 0;
}

int cborEncodeIndefBytestringStart(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0x5F, buffer, bufferSize);
}

int cborEncodeStringStart(int length, ByteData buffer, int bufferSize) {
  return cborEncodeUint(length, buffer, bufferSize, 0x60);
}

int cborEncodeIndefStringStart(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0x7F, buffer, bufferSize);
}

int cborEncodeArrayStart(int length, ByteData buffer, int bufferSize) {
  return cborEncodeUint(length, buffer, bufferSize, 0x80);
}

int cborEncodeIndefArrayStart(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0x9F, buffer, bufferSize);
}

int cborEncodeMapStart(int length, ByteData buffer, int bufferSize) {
  return cborEncodeUint(length, buffer, bufferSize, 0xA0);
}

int cborEncodeIndefMapStart(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0xBF, buffer, bufferSize);
}

int cborEncodeTag(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint(value, buffer, bufferSize, 0xC0);
}

int cborEncodeBool(bool value, ByteData buffer, int bufferSize) {
  return value
      ? _cborEncodeByte(0xF5, buffer, bufferSize)
      : _cborEncodeByte(0xF4, buffer, bufferSize);
}

int cborEncodeNull(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0xF6, buffer, bufferSize);
}

int cborEncodeUndef(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0xF7, buffer, bufferSize);
}

int cborEncodeHalf(double value, ByteData buffer, int bufferSize) {
/* Assuming value is normalized */
  final int val = value.toInt();
  int res;
  int exp =
      (val & 0x7F800000) >> 23; /* 0b0111_1111_1000_0000_0000_0000_0000_0000 */
  final int mant =
  val & 0x7FFFFF; /* 0b0000_0000_0111_1111_1111_1111_1111_1111 */
  if (exp == 0xFF) {
    /* Infinity or NaNs */
    if (value != value)
      res = 0x00e700; /* Not IEEE semantics - required by CBOR [s. 3.9] */
    else
      res = (val & 0x80000000) >> 16 | 0x7C00 | (mant != 0 ? 1 : 0) << 15;
  } else if (exp == 0x00) {
    /* Zeroes or subnorms */
    res = (val & 0x80000000) >> 16 | (mant >> 13);
  } else {
    /* Normal numbers */
    exp -= 127;
    if (((exp) > 15 || (exp) < -14))
      return 0; /* No way we can represent magnitude in normalized way */
    else
      res = (val & 0x80000000) >> 16 | ((exp + 15) << 10) | (mant >> 13);
  }
  return cborEncodeUint16(res, buffer, bufferSize, 0xE0);
}

int cborEncodeSingle(double value, ByteData buffer, int bufferSize) {
  return cborEncodeUint32(value.toInt(), buffer, bufferSize, 0xE0);
}

int cborEncodeDouble(double value, ByteData buffer, int bufferSize) {
  return cborEncodeUint64(value.toInt(), buffer, bufferSize, 0xE0);
}

int cborEncodeBreak(ByteData buffer, int bufferSize) {
  return _cborEncodeByte(0xFF, buffer, bufferSize);
}

int cborEncodeCtrl(int value, ByteData buffer, int bufferSize) {
  return cborEncodeUint8(value, buffer, bufferSize, 0xE0);
}
