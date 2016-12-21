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

int cborEncodeUint8(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint8Max);
  if (value <= 23) {
    if (bufferSize >= 1) {
      buffer.setUint8(0, value);
      return 1;
    }
  } else {
    if (bufferSize >= 2) {
      buffer.setUint8(0, 0x18);
      buffer.setUint8(1, value);
      return 2;
    }
  }
  return 0;
}

int cborEncodeUint16(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint16Max);
  if (bufferSize >= 3) {
    buffer.setUint8(0, 0x19);
    buffer.setUint16(1, value);
    return 3;
  } else {
    return 0;
  }
}

int cborEncodeUint32(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint32Max);
  if (bufferSize >= 5) {
    buffer.setUint8(0, 0x1A);
    buffer.setUint32(1, value);
    return 5;
  } else {
    return 0;
  }
}

int cborEncodeUint64(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint64Max);
  if (bufferSize >= 9) {
    buffer.setUint8(0, 0x1B);
    buffer.setUint64(1, value);
    return 9;
  } else {
    return 0;
  }
}

int cborEncodeUint(int value, ByteData buffer, int bufferSize) {
  if (value <= uint16Max)
    if (value <= uint8Max)
      return cborEncodeUint8(value, buffer, bufferSize);
    else
      return cborEncodeUint16(value, buffer, bufferSize);
  else if (value <= uint32Max)
    return cborEncodeUint32(value, buffer, bufferSize);
  else
    return cborEncodeUint64(value, buffer, bufferSize);
}

int cborEncodeNegint8(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint8Max);
  if (value <= 23) {
    if (bufferSize >= 1) {
      buffer.setUint8(0, value + 0x20);
      return 1;
    }
  } else {
    if (bufferSize >= 2) {
      buffer.setUint8(0, 0x18 + 0x20);
      buffer.setUint8(1, value);
      return 2;
    }
  }
  return 0;
}

int cborEncodeNegint16(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint16Max);
  if (bufferSize >= 3) {
    buffer.setUint8(0, 0x19 + 0x20);
    buffer.setUint16(1, value);
    return 3;
  } else {
    return 0;
  }
}

int cborEncodeNegint32(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint32Max);
  if (bufferSize >= 5) {
    buffer.setUint8(0, 0x1A + 0x20);
    buffer.setUint32(1, value);
    return 5;
  } else {
    return 0;
  }
}

int cborEncodeNegint64(int value, ByteData buffer, int bufferSize) {
  assert(value >= 0 && value <= uint64Max);
  if (bufferSize >= 9) {
    buffer.setUint8(0, 0x1B + 0x20);
    buffer.setUint64(1, value);
    return 9;
  } else {
    return 0;
  }
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
