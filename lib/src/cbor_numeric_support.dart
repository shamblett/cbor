/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Numeric handling support functions.

/// Float handling support functions.

/// Gets a half precision float from its int
/// value.
double getHalfPrecisionDouble(int val) {
  int t1 = val & 0x7fff; // Non-sign bits
  int t2 = val & 0x8000; // Sign bit
  final int t3 = val & 0x7c00; // Exponent
  t1 <<= 13; // Align mantissa on MSB
  t2 <<= 16; // Shift sign bit into position
  t1 += 0x38000000; // Adjust bias
  t1 = t3 == 0 ? 0 : t1; // Denormalise as zero
  t1 |= t2; // re-insert sign bit
  final List<int> tmp = <int>[];
  tmp.add((t1 >> 24) & 0xff);
  tmp.add((t1 >> 16) & 0xff);
  tmp.add((t1 >> 8) & 0xff);
  tmp.add(t1 & 0xff);
  final typed.Uint8Buffer buff = typed.Uint8Buffer();
  buff.addAll(tmp);
  final ByteData bdata = ByteData.view(buff.buffer);
  final double ret = bdata.getFloat32(0);
  return ret;
}

/// Gets a half precision integer value from a
/// float.
int getHalfPrecisionInt(double val) {
  final typed.Float32Buffer fBuff = typed.Float32Buffer(1);
  fBuff[0] = val;
  final ByteBuffer bBuff = fBuff.buffer;
  final Uint8List uList = bBuff.asUint8List();
  final int intVal = uList[0] | uList[1] << 8 | uList[2] << 16 | uList[3] << 24;
  final int index = intVal >> 23;
  final int masked = intVal & 0x7FFFFF;
  final int hBits = baseTable[index] + (masked >> shiftTable[index]);
  return hBits;
}

/// Check if a double can be represented as half precision.
/// Returns true if it can be.
bool canBeAHalf(double value) {
  // Convert to half and back again.
  final int half = getHalfPrecisionInt(value);
  final double result = getHalfPrecisionDouble(half);
  // If the value is the same it can be converted.
  return result == value;
}

/// Check if a double can be represented as single precision.
/// Returns true if it can.
bool canBeASingle(double value) {
  /// Convert to single and back again.
  final typed.Float32Buffer fBuff = typed.Float32Buffer(1);
  fBuff[0] = value;
  // If the value is the same it can be converted.
  final double result = fBuff[0];
  return value == result;
}

/// Bignum functions

/// Bignum byte buffer to BigInt. Returns null
/// if the conversion fails.
BigInt bignumToBigInt(typed.Uint8Buffer buff, String sign) {
  // Convert to a signed hex string.
  String res = '${sign}0x';
  for (final int i in buff) {
    String tmp = i.toRadixString(16);
    if (tmp.length == 1) {
      tmp = '0$tmp';
    }
    // ignore: use_string_buffers
    res += tmp;
  }
  return BigInt.tryParse(res);
}
