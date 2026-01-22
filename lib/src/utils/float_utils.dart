/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/01/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

/// Custom half-precision (float16) encoding/decoding that works correctly on all platforms.
///
/// ## Why custom implementation?
///
/// The ieee754 package has issues on JavaScript platforms:
///
/// ### Encoding (`toFloat16Bytes`)
/// The ieee754 package uses `ByteData.setInt16()` which behaves incorrectly on JS
/// where bitwise operators are limited to 32-bit signed integers. When the sign bit
/// is set (negative numbers, negative zero), the value gets sign-extended incorrectly.
///
/// ### Decoding (`fromFloat16Bytes`)
/// The ieee754 package uses `ByteData.getInt16()` to read the 16-bit value, which
/// on JS interprets the bytes as a signed integer. For values with the high bit set
/// (negative numbers, large positive exponents), this produces incorrect results.
/// For example, -4.0 (bytes 0xC400) gets decoded as -33554428 instead of -4.0.
///
/// This implementation avoids these issues by:
/// - Constructing bytes directly without using setInt16/getInt16
/// - Using only unsigned byte operations that work consistently across platforms
/// - Building the 16-bit value from individual bytes using shifts and OR operations

/// Converts a double to IEEE 754 half-precision (16-bit) bytes in big-endian order.
///
/// Returns a list of 2 bytes `[highByte, lowByte]`.
List<int> toFloat16Bytes(double value) {
  // Handle special cases
  if (value.isNaN) {
    // Canonical NaN: 0x7e00
    return [0x7e, 0x00];
  }

  if (value.isInfinite) {
    // +Infinity: 0x7c00, -Infinity: 0xfc00
    return value.isNegative ? [0xfc, 0x00] : [0x7c, 0x00];
  }

  // Handle zero (including signed zero)
  if (value == 0.0) {
    // Check for negative zero
    final bytes = Uint8List(8);
    ByteData.view(bytes.buffer).setFloat64(0, value, Endian.big);
    final isNegativeZero = bytes[0] == 0x80;
    return isNegativeZero ? [0x80, 0x00] : [0x00, 0x00];
  }

  // Extract components from double using ByteData
  final doubleBytes = Uint8List(8);
  ByteData.view(doubleBytes.buffer).setFloat64(0, value, Endian.big);

  // Extract sign, exponent, and mantissa from IEEE 754 double (64-bit)
  // Double format: 1 sign + 11 exponent + 52 mantissa
  final sign = (doubleBytes[0] >> 7) & 1;
  final exponent =
      ((doubleBytes[0] & 0x7F) << 4) | ((doubleBytes[1] >> 4) & 0x0F);
  // We only need the top 10 bits of the mantissa for half-precision
  final mantissaHigh =
      ((doubleBytes[1] & 0x0F) << 6) | ((doubleBytes[2] >> 2) & 0x3F);

  // Double exponent bias is 1023, half-precision bias is 15
  // Adjust exponent: half_exp = double_exp - 1023 + 15 = double_exp - 1008
  final adjustedExponent = exponent - 1023 + 15;

  int halfSign = sign;
  int halfExponent;
  int halfMantissa;

  if (adjustedExponent <= 0) {
    // Subnormal or zero in half-precision
    if (adjustedExponent < -10) {
      // Too small, round to zero
      halfExponent = 0;
      halfMantissa = 0;
    } else {
      // Subnormal: shift mantissa right and add implicit leading 1
      halfExponent = 0;
      final shift = 1 - adjustedExponent;
      // Add implicit leading bit and shift
      halfMantissa = (0x400 | mantissaHigh) >> shift;
    }
  } else if (adjustedExponent >= 31) {
    // Overflow to infinity
    halfExponent = 31;
    halfMantissa = 0;
  } else {
    // Normal number
    halfExponent = adjustedExponent;
    halfMantissa = mantissaHigh;
  }

  // Construct the 16-bit half-precision value
  // Format: 1 sign + 5 exponent + 10 mantissa
  final halfValue = (halfSign << 15) | (halfExponent << 10) | halfMantissa;

  // Return as big-endian bytes
  return [(halfValue >> 8) & 0xFF, halfValue & 0xFF];
}

/// Check if a double can be represented losslessly as a half-precision float.
///
/// This is a cross-platform implementation that doesn't rely on platform-specific
/// behavior.
bool isFloat16Lossless(double value) {
  // Special values are always lossless
  if (value.isNaN || value.isInfinite || value == 0.0) {
    return true;
  }

  // Convert to float16 and back, check if value is preserved
  final halfBytes = toFloat16Bytes(value);
  final reconstructed = fromFloat16Bytes(halfBytes);

  return reconstructed == value;
}

/// Converts IEEE 754 half-precision (16-bit) bytes to a double.
///
/// Expects 2 bytes in big-endian order `[highByte, lowByte]`.
///
/// This is a cross-platform implementation that avoids `ByteData.getInt16()`
/// which behaves incorrectly on JS for values with the high bit set.
double fromFloat16Bytes(List<int> bytes) {
  final halfValue = (bytes[0] << 8) | bytes[1];

  final sign = (halfValue >> 15) & 1;
  final exponent = (halfValue >> 10) & 0x1F;
  final mantissa = halfValue & 0x3FF;

  double result;

  if (exponent == 0) {
    if (mantissa == 0) {
      // Zero
      result = 0.0;
    } else {
      // Subnormal
      result = mantissa / 1024.0 * (1.0 / 16384.0); // 2^-14
    }
  } else if (exponent == 31) {
    if (mantissa == 0) {
      result = double.infinity;
    } else {
      result = double.nan;
    }
  } else {
    // Normal number
    result = (1.0 + mantissa / 1024.0) * _pow2(exponent - 15);
  }

  return sign == 1 ? -result : result;
}

/// Power of 2 helper that avoids dart:math dependency.
double _pow2(int exp) {
  if (exp >= 0) {
    double result = 1.0;
    for (var i = 0; i < exp; i++) {
      result *= 2.0;
    }
    return result;
  } else {
    double result = 1.0;
    for (var i = 0; i > exp; i--) {
      result /= 2.0;
    }
    return result;
  }
}

/// Check if a double can be represented losslessly as a single-precision (32-bit) float.
///
/// This is a cross-platform implementation.
bool isFloat32Lossless(double value) {
  // Special values are always lossless
  if (value.isNaN || value.isInfinite || value == 0.0) {
    return true;
  }

  // Convert to float32 and back, check if value is preserved
  final bytes = toFloat32Bytes(value);
  final reconstructed = fromFloat32Bytes(bytes);

  return reconstructed == value;
}

/// Check if a double can be represented losslessly as a double-precision (64-bit) float.
///
/// This always returns true since Dart doubles are already 64-bit IEEE 754 floats.
bool isFloat64Lossless(double value) {
  return true;
}

/// Converts a double to IEEE 754 single-precision (32-bit) bytes in big-endian order.
///
/// Returns a list of 4 bytes.
List<int> toFloat32Bytes(double value) {
  final bytes = Uint8List(4);
  ByteData.view(bytes.buffer).setFloat32(0, value, Endian.big);
  return bytes;
}

/// Converts IEEE 754 single-precision (32-bit) bytes to a double.
///
/// Expects 4 bytes in big-endian order.
double fromFloat32Bytes(List<int> bytes) {
  final data = ByteData.view(Uint8List.fromList(bytes).buffer);
  return data.getFloat32(0, Endian.big);
}

/// Converts a double to IEEE 754 double-precision (64-bit) bytes in big-endian order.
///
/// Returns a list of 8 bytes.
List<int> toFloat64Bytes(double value) {
  final bytes = Uint8List(8);
  ByteData.view(bytes.buffer).setFloat64(0, value, Endian.big);
  return bytes;
}

/// Converts IEEE 754 double-precision (64-bit) bytes to a double.
///
/// Expects 8 bytes in big-endian order.
double fromFloat64Bytes(List<int> bytes) {
  final data = ByteData.view(Uint8List.fromList(bytes).buffer);
  return data.getFloat64(0, Endian.big);
}
