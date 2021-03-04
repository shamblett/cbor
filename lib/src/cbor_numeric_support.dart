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
  var t1 = val & 0x7fff; // Non-sign bits
  var t2 = val & 0x8000; // Sign bit
  final t3 = val & 0x7c00; // Exponent
  t1 <<= 13; // Align mantissa on MSB
  t2 <<= 16; // Shift sign bit into position
  t1 += 0x38000000; // Adjust bias
  t1 = t3 == 0 ? 0 : t1; // Denormalise as zero
  t1 |= t2; // re-insert sign bit
  final tmp = <int>[];
  tmp.add((t1 >> 24) & 0xff);
  tmp.add((t1 >> 16) & 0xff);
  tmp.add((t1 >> 8) & 0xff);
  tmp.add(t1 & 0xff);
  final buff = typed.Uint8Buffer();
  buff.addAll(tmp);
  final bdata = ByteData.view(buff.buffer);
  final ret = bdata.getFloat32(0);
  return ret;
}

/// Gets a half precision integer value from a
/// float.
int getHalfPrecisionInt(double val) {
  final fBuff = typed.Float32Buffer(1);
  fBuff[0] = val;
  final bBuff = fBuff.buffer;
  final uList = bBuff.asUint8List();
  final intVal = uList[0] | uList[1] << 8 | uList[2] << 16 | uList[3] << 24;
  final index = intVal >> 23;
  final masked = intVal & 0x7FFFFF;
  final hBits = baseTable[index] + (masked >> shiftTable[index]);
  return hBits;
}

/// Check if a double can be represented as half precision.
/// Returns true if it can be.
bool canBeAHalf(double value) {
  // Convert to half and back again.
  final half = getHalfPrecisionInt(value);
  final result = getHalfPrecisionDouble(half);
  // If the value is the same it can be converted.
  return result == value;
}

/// Check if a double can be represented as single precision.
/// Returns true if it can.
bool canBeASingle(double value) {
  /// Convert to single and back again.
  final fBuff = typed.Float32Buffer(1);
  fBuff[0] = value;
  // If the value is the same it can be converted.
  final result = fBuff[0];
  return value == result;
}

/// Bignum functions

/// Bignum byte buffer to BigInt. Returns null
/// if the conversion fails.
BigInt? bignumToBigInt(typed.Uint8Buffer buff, String sign) {
  // Convert to a signed hex string.
  final res = StringBuffer();
  res.write('${sign}0x');
  for (final i in buff) {
    var tmp = i.toRadixString(16);
    if (tmp.length == 1) {
      tmp = '0$tmp';
    }
    res.write(tmp);
  }
  return BigInt.tryParse(res.toString());
}

/// Convert a hex string to a [ByteBuffer] of bytes.
ByteBuffer? hexToBytes(String? input) {
  if (input == null) {
    return null;
  }
  final s = input.replaceAll(' ', '').replaceAll(':', '').replaceAll('\n', '');
  if (s.length % 2 != 0) {
    throw ArgumentError.value(input);
  }
  final result = Uint8List(s.length ~/ 2);
  for (var i = 0; i < s.length; i += 2) {
    var value = int.tryParse(s.substring(i, i + 2), radix: 16);
    if (value == null) {
      throw ArgumentError.value(input, 'input');
    }
    result[i ~/ 2] = value;
  }
  return Uint8List.fromList(result).buffer;
}
