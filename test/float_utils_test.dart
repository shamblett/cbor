/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/01/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/src/utils/float_utils.dart';
import 'package:ieee754/ieee754.dart' as ieee754;
import 'package:test/test.dart';

/// Platform detection: identical(0, 0.0) returns true only on JS.
final bool _kIsJs = identical(0, 0.0);

// Helper functions to validate against ieee754 package on non-JS platforms.
// On JS, ieee754 has known issues with setInt16/getInt16, so we skip validation there.

/// Validates that toFloat16Bytes matches ieee754 (non-JS only).
void _validateFloat16Encoding(double value, List<int> result) {
  if (_kIsJs) return;
  final ieee754Bytes = ieee754.FloatParts.fromDouble(value).toFloat16Bytes();
  if (value.isNaN) {
    // NaN can have different representations, just verify both decode to NaN
    expect(fromFloat16Bytes(result).isNaN, true);
    expect(
      ieee754.FloatParts.fromFloat16Bytes(ieee754Bytes).toDouble().isNaN,
      true,
    );
  } else {
    expect(result, ieee754Bytes, reason: 'Should match ieee754 for $value');
  }
}

/// Validates that fromFloat16Bytes matches ieee754 (non-JS only).
void _validateFloat16Decoding(List<int> bytes, double result) {
  if (_kIsJs) return;
  final ieee754Value =
      ieee754.FloatParts.fromFloat16Bytes(Uint8List.fromList(bytes)).toDouble();
  if (ieee754Value.isNaN) {
    expect(result.isNaN, true);
  } else {
    expect(result, ieee754Value, reason: 'Should match ieee754');
  }
}

/// Validates that toFloat32Bytes matches ieee754 (non-JS only).
void _validateFloat32Encoding(double value, List<int> result) {
  if (_kIsJs) return;
  final ieee754Bytes = ieee754.FloatParts.fromDouble(value).toFloat32Bytes();
  if (value.isNaN) {
    expect(fromFloat32Bytes(result).isNaN, true);
    expect(
      ieee754.FloatParts.fromFloat32Bytes(ieee754Bytes).toDouble().isNaN,
      true,
    );
  } else {
    expect(result, ieee754Bytes, reason: 'Should match ieee754 for $value');
  }
}

/// Validates that fromFloat32Bytes matches ieee754 (non-JS only).
void _validateFloat32Decoding(List<int> bytes, double result) {
  if (_kIsJs) return;
  final ieee754Value =
      ieee754.FloatParts.fromFloat32Bytes(Uint8List.fromList(bytes)).toDouble();
  if (ieee754Value.isNaN) {
    expect(result.isNaN, true);
  } else {
    expect(result, ieee754Value, reason: 'Should match ieee754');
  }
}

/// Validates that toFloat64Bytes matches ieee754 (non-JS only).
void _validateFloat64Encoding(double value, List<int> result) {
  if (_kIsJs) return;
  final ieee754Bytes = ieee754.FloatParts.fromDouble(value).toFloat64Bytes();
  if (value.isNaN) {
    expect(fromFloat64Bytes(result).isNaN, true);
    expect(
      ieee754.FloatParts.fromFloat64Bytes(ieee754Bytes).toDouble().isNaN,
      true,
    );
  } else {
    expect(result, ieee754Bytes, reason: 'Should match ieee754 for $value');
  }
}

/// Validates that fromFloat64Bytes matches ieee754 (non-JS only).
void _validateFloat64Decoding(List<int> bytes, double result) {
  if (_kIsJs) return;
  final ieee754Value =
      ieee754.FloatParts.fromFloat64Bytes(Uint8List.fromList(bytes)).toDouble();
  if (ieee754Value.isNaN) {
    expect(result.isNaN, true);
  } else {
    expect(result, ieee754Value, reason: 'Should match ieee754');
  }
}

/// Validates that isFloat16Lossless matches ieee754 (non-JS only).
void _validateIsFloat16Lossless(double value, bool result) {
  if (_kIsJs) return;
  final ieee754Result = ieee754.FloatParts.fromDouble(value).isFloat16Lossless;
  expect(result, ieee754Result, reason: 'Should match ieee754 for $value');
}

/// Validates that isFloat32Lossless matches ieee754 (non-JS only).
void _validateIsFloat32Lossless(double value, bool result) {
  if (_kIsJs) return;
  final ieee754Result = ieee754.FloatParts.fromDouble(value).isFloat32Lossless;
  expect(result, ieee754Result, reason: 'Should match ieee754 for $value');
}

void main() {
  group('Float16 (half-precision) encoding - toFloat16Bytes', () {
    group('Special values', () {
      test('NaN encodes to canonical NaN (0x7e00)', () {
        final result = toFloat16Bytes(double.nan);
        expect(result, [0x7e, 0x00]);
        _validateFloat16Encoding(double.nan, result);
      });

      test('+Infinity encodes to 0x7c00', () {
        final result = toFloat16Bytes(double.infinity);
        expect(result, [0x7c, 0x00]);
        _validateFloat16Encoding(double.infinity, result);
      });

      test('-Infinity encodes to 0xfc00', () {
        final result = toFloat16Bytes(double.negativeInfinity);
        expect(result, [0xfc, 0x00]);
        _validateFloat16Encoding(double.negativeInfinity, result);
      });

      test('+0.0 encodes to 0x0000', () {
        final result = toFloat16Bytes(0.0);
        expect(result, [0x00, 0x00]);
        _validateFloat16Encoding(0.0, result);
      });

      test('-0.0 encodes to 0x8000', () {
        final result = toFloat16Bytes(-0.0);
        expect(result, [0x80, 0x00]);
        _validateFloat16Encoding(-0.0, result);
      });
    });

    group('Normal positive values', () {
      test('1.0 encodes to 0x3c00', () {
        final result = toFloat16Bytes(1.0);
        expect(result, [0x3c, 0x00]);
        _validateFloat16Encoding(1.0, result);
      });

      test('1.5 encodes to 0x3e00', () {
        final result = toFloat16Bytes(1.5);
        expect(result, [0x3e, 0x00]);
        _validateFloat16Encoding(1.5, result);
      });

      test('2.0 encodes to 0x4000', () {
        final result = toFloat16Bytes(2.0);
        expect(result, [0x40, 0x00]);
        _validateFloat16Encoding(2.0, result);
      });

      test('0.5 encodes to 0x3800', () {
        final result = toFloat16Bytes(0.5);
        expect(result, [0x38, 0x00]);
        _validateFloat16Encoding(0.5, result);
      });

      test('65504.0 (max normal) encodes to 0x7bff', () {
        final result = toFloat16Bytes(65504.0);
        expect(result, [0x7b, 0xff]);
        _validateFloat16Encoding(65504.0, result);
      });

      test('0.00006103515625 (min positive normal) encodes to 0x0400', () {
        final result = toFloat16Bytes(0.00006103515625);
        expect(result, [0x04, 0x00]);
        _validateFloat16Encoding(0.00006103515625, result);
      });
    });

    group('Normal negative values', () {
      test('-1.0 encodes to 0xbc00', () {
        final result = toFloat16Bytes(-1.0);
        expect(result, [0xbc, 0x00]);
        _validateFloat16Encoding(-1.0, result);
      });

      test('-1.5 encodes to 0xbe00', () {
        final result = toFloat16Bytes(-1.5);
        expect(result, [0xbe, 0x00]);
        _validateFloat16Encoding(-1.5, result);
      });

      test('-2.0 encodes to 0xc000', () {
        final result = toFloat16Bytes(-2.0);
        expect(result, [0xc0, 0x00]);
        _validateFloat16Encoding(-2.0, result);
      });

      test('-4.0 encodes to 0xc400', () {
        final result = toFloat16Bytes(-4.0);
        expect(result, [0xc4, 0x00]);
        _validateFloat16Encoding(-4.0, result);
      });

      test('-65504.0 (min normal) encodes to 0xfbff', () {
        final result = toFloat16Bytes(-65504.0);
        expect(result, [0xfb, 0xff]);
        _validateFloat16Encoding(-65504.0, result);
      });
    });

    group('Subnormal values', () {
      test('5.960464477539063e-8 (smallest subnormal) encodes to 0x0001', () {
        final result = toFloat16Bytes(5.960464477539063e-8);
        expect(result, [0x00, 0x01]);
        _validateFloat16Encoding(5.960464477539063e-8, result);
      });

      test('6.097555160522461e-5 (largest subnormal) encodes to 0x03ff', () {
        final result = toFloat16Bytes(6.097555160522461e-5);
        expect(result, [0x03, 0xff]);
        _validateFloat16Encoding(6.097555160522461e-5, result);
      });
    });

    group('Overflow to infinity', () {
      test('65536.0 overflows to +Infinity', () {
        final result = toFloat16Bytes(65536.0);
        expect(result, [0x7c, 0x00]);
        _validateFloat16Encoding(65536.0, result);
      });

      test('100000.0 overflows to +Infinity', () {
        final result = toFloat16Bytes(100000.0);
        expect(result, [0x7c, 0x00]);
        _validateFloat16Encoding(100000.0, result);
      });

      test('-100000.0 overflows to -Infinity', () {
        final result = toFloat16Bytes(-100000.0);
        expect(result, [0xfc, 0x00]);
        _validateFloat16Encoding(-100000.0, result);
      });
    });

    group('Underflow to zero', () {
      test('Very small positive value underflows to +0', () {
        final result = toFloat16Bytes(1e-10);
        expect(result, [0x00, 0x00]);
        _validateFloat16Encoding(1e-10, result);
      });

      test('Very small negative value underflows to -0', () {
        final result = toFloat16Bytes(-1e-10);
        expect(result, [0x80, 0x00]);
        _validateFloat16Encoding(-1e-10, result);
      });
    });

    group('RFC 8949 Appendix A test vectors', () {
      test('0.0', () {
        final result = toFloat16Bytes(0.0);
        expect(result, [0x00, 0x00]);
        _validateFloat16Encoding(0.0, result);
      });
      test('-0.0', () {
        final result = toFloat16Bytes(-0.0);
        expect(result, [0x80, 0x00]);
        _validateFloat16Encoding(-0.0, result);
      });
      test('1.0', () {
        final result = toFloat16Bytes(1.0);
        expect(result, [0x3c, 0x00]);
        _validateFloat16Encoding(1.0, result);
      });
      test('1.5', () {
        final result = toFloat16Bytes(1.5);
        expect(result, [0x3e, 0x00]);
        _validateFloat16Encoding(1.5, result);
      });
      test('65504.0', () {
        final result = toFloat16Bytes(65504.0);
        expect(result, [0x7b, 0xff]);
        _validateFloat16Encoding(65504.0, result);
      });
      test('5.960464477539063e-8', () {
        final result = toFloat16Bytes(5.960464477539063e-8);
        expect(result, [0x00, 0x01]);
        _validateFloat16Encoding(5.960464477539063e-8, result);
      });
      test('0.00006103515625', () {
        final result = toFloat16Bytes(0.00006103515625);
        expect(result, [0x04, 0x00]);
        _validateFloat16Encoding(0.00006103515625, result);
      });
      test('-4.0', () {
        final result = toFloat16Bytes(-4.0);
        expect(result, [0xc4, 0x00]);
        _validateFloat16Encoding(-4.0, result);
      });
    });
  });

  group('Float16 (half-precision) decoding - fromFloat16Bytes', () {
    group('Special values', () {
      test('0x7e00 decodes to NaN', () {
        const bytes = [0x7e, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result.isNaN, true);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x7c01 (NaN with payload) decodes to NaN', () {
        const bytes = [0x7c, 0x01];
        final result = fromFloat16Bytes(bytes);
        expect(result.isNaN, true);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x7c00 decodes to +Infinity', () {
        const bytes = [0x7c, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, double.infinity);
        _validateFloat16Decoding(bytes, result);
      });

      test('0xfc00 decodes to -Infinity', () {
        const bytes = [0xfc, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, double.negativeInfinity);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x0000 decodes to +0.0', () {
        const bytes = [0x00, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 0.0);
        expect(result.isNegative, false);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x8000 decodes to -0.0', () {
        const bytes = [0x80, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 0.0);
        expect(result.isNegative, true);
        _validateFloat16Decoding(bytes, result);
      });
    });

    group('Normal positive values', () {
      test('0x3c00 decodes to 1.0', () {
        const bytes = [0x3c, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 1.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x3e00 decodes to 1.5', () {
        const bytes = [0x3e, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 1.5);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x4000 decodes to 2.0', () {
        const bytes = [0x40, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 2.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x3800 decodes to 0.5', () {
        const bytes = [0x38, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 0.5);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x7bff decodes to 65504.0', () {
        const bytes = [0x7b, 0xff];
        final result = fromFloat16Bytes(bytes);
        expect(result, 65504.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x0400 decodes to 0.00006103515625', () {
        const bytes = [0x04, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, 0.00006103515625);
        _validateFloat16Decoding(bytes, result);
      });
    });

    group('Normal negative values', () {
      test('0xbc00 decodes to -1.0', () {
        const bytes = [0xbc, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, -1.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0xbe00 decodes to -1.5', () {
        const bytes = [0xbe, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, -1.5);
        _validateFloat16Decoding(bytes, result);
      });

      test('0xc000 decodes to -2.0', () {
        const bytes = [0xc0, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, -2.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0xc400 decodes to -4.0', () {
        const bytes = [0xc4, 0x00];
        final result = fromFloat16Bytes(bytes);
        expect(result, -4.0);
        _validateFloat16Decoding(bytes, result);
      });

      test('0xfbff decodes to -65504.0', () {
        const bytes = [0xfb, 0xff];
        final result = fromFloat16Bytes(bytes);
        expect(result, -65504.0);
        _validateFloat16Decoding(bytes, result);
      });
    });

    group('Subnormal values', () {
      test('0x0001 decodes to smallest subnormal', () {
        const bytes = [0x00, 0x01];
        final result = fromFloat16Bytes(bytes);
        expect(result, 5.960464477539063e-8);
        _validateFloat16Decoding(bytes, result);
      });

      test('0x03ff decodes to largest subnormal', () {
        const bytes = [0x03, 0xff];
        final result = fromFloat16Bytes(bytes);
        expect(result, 6.097555160522461e-5);
        _validateFloat16Decoding(bytes, result);
      });
    });
  });

  group('Float16 round-trip tests', () {
    test('All representable values round-trip correctly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        1.5,
        -1.5,
        2.0,
        -2.0,
        0.5,
        -0.5,
        0.25,
        -0.25,
        65504.0,
        -65504.0,
        0.00006103515625,
        -0.00006103515625,
        5.960464477539063e-8,
        double.infinity,
        double.negativeInfinity,
      ];

      for (final value in testValues) {
        final bytes = toFloat16Bytes(value);
        final decoded = fromFloat16Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else {
          expect(decoded, value, reason: '$value should round-trip');
        }
        _validateFloat16Encoding(value, bytes);
      }
    });

    test('NaN round-trips', () {
      final bytes = toFloat16Bytes(double.nan);
      expect(fromFloat16Bytes(bytes).isNaN, true);
      _validateFloat16Encoding(double.nan, bytes);
    });
  });

  group('isFloat16Lossless', () {
    group('Values that can be represented', () {
      test('Special values', () {
        expect(isFloat16Lossless(0.0), true);
        _validateIsFloat16Lossless(0.0, true);
        expect(isFloat16Lossless(-0.0), true);
        _validateIsFloat16Lossless(-0.0, true);
        expect(isFloat16Lossless(double.nan), true);
        _validateIsFloat16Lossless(double.nan, true);
        expect(isFloat16Lossless(double.infinity), true);
        _validateIsFloat16Lossless(double.infinity, true);
        expect(isFloat16Lossless(double.negativeInfinity), true);
        _validateIsFloat16Lossless(double.negativeInfinity, true);
      });

      test('Exact representable values', () {
        expect(isFloat16Lossless(1.0), true);
        _validateIsFloat16Lossless(1.0, true);
        expect(isFloat16Lossless(-1.0), true);
        _validateIsFloat16Lossless(-1.0, true);
        expect(isFloat16Lossless(1.5), true);
        _validateIsFloat16Lossless(1.5, true);
        expect(isFloat16Lossless(2.0), true);
        _validateIsFloat16Lossless(2.0, true);
        expect(isFloat16Lossless(65504.0), true);
        _validateIsFloat16Lossless(65504.0, true);
        expect(isFloat16Lossless(0.00006103515625), true);
        _validateIsFloat16Lossless(0.00006103515625, true);
        expect(isFloat16Lossless(5.960464477539063e-8), true);
        _validateIsFloat16Lossless(5.960464477539063e-8, true);
      });
    });

    group('Values that cannot be represented', () {
      test('Values too large', () {
        expect(isFloat16Lossless(100000.0), false);
        _validateIsFloat16Lossless(100000.0, false);
        expect(isFloat16Lossless(65536.0), false);
        _validateIsFloat16Lossless(65536.0, false);
      });

      test('Values with too much precision', () {
        expect(isFloat16Lossless(1.1), false);
        _validateIsFloat16Lossless(1.1, false);
        expect(isFloat16Lossless(3.14159), false);
        _validateIsFloat16Lossless(3.14159, false);
        expect(isFloat16Lossless(1.0001), false);
        _validateIsFloat16Lossless(1.0001, false);
      });

      test('Values too small (non-zero)', () {
        expect(isFloat16Lossless(1e-10), false);
        _validateIsFloat16Lossless(1e-10, false);
      });
    });
  });

  group('Float32 (single-precision) encoding - toFloat32Bytes', () {
    group('Special values', () {
      test('NaN encodes correctly', () {
        final bytes = toFloat32Bytes(double.nan);
        expect(bytes.length, 4);
        // NaN has exponent all 1s and non-zero mantissa
        expect(bytes[0] & 0x7F, 0x7F); // High bit of exponent
        expect(bytes[1] & 0x80, 0x80); // Low bit of exponent
        _validateFloat32Encoding(double.nan, bytes);
      });

      test('+Infinity encodes to 0x7f800000', () {
        final result = toFloat32Bytes(double.infinity);
        expect(result, [0x7f, 0x80, 0x00, 0x00]);
        _validateFloat32Encoding(double.infinity, result);
      });

      test('-Infinity encodes to 0xff800000', () {
        final result = toFloat32Bytes(double.negativeInfinity);
        expect(result, [0xff, 0x80, 0x00, 0x00]);
        _validateFloat32Encoding(double.negativeInfinity, result);
      });

      test('+0.0 encodes to 0x00000000', () {
        final result = toFloat32Bytes(0.0);
        expect(result, [0x00, 0x00, 0x00, 0x00]);
        _validateFloat32Encoding(0.0, result);
      });

      test('-0.0 encodes to 0x80000000', () {
        final result = toFloat32Bytes(-0.0);
        expect(result, [0x80, 0x00, 0x00, 0x00]);
        _validateFloat32Encoding(-0.0, result);
      });
    });

    group('Normal values', () {
      test('1.0 encodes to 0x3f800000', () {
        final result = toFloat32Bytes(1.0);
        expect(result, [0x3f, 0x80, 0x00, 0x00]);
        _validateFloat32Encoding(1.0, result);
      });

      test('-1.0 encodes to 0xbf800000', () {
        final result = toFloat32Bytes(-1.0);
        expect(result, [0xbf, 0x80, 0x00, 0x00]);
        _validateFloat32Encoding(-1.0, result);
      });

      test('2.0 encodes to 0x40000000', () {
        final result = toFloat32Bytes(2.0);
        expect(result, [0x40, 0x00, 0x00, 0x00]);
        _validateFloat32Encoding(2.0, result);
      });

      test('0.5 encodes to 0x3f000000', () {
        final result = toFloat32Bytes(0.5);
        expect(result, [0x3f, 0x00, 0x00, 0x00]);
        _validateFloat32Encoding(0.5, result);
      });

      test('100000.0 encodes to 0x47c35000', () {
        final result = toFloat32Bytes(100000.0);
        expect(result, [0x47, 0xc3, 0x50, 0x00]);
        _validateFloat32Encoding(100000.0, result);
      });

      test('3.4028234663852886e+38 (max float32)', () {
        final result = toFloat32Bytes(3.4028234663852886e+38);
        expect(result, [0x7f, 0x7f, 0xff, 0xff]);
        _validateFloat32Encoding(3.4028234663852886e+38, result);
      });
    });
  });

  group('Float32 (single-precision) decoding - fromFloat32Bytes', () {
    group('Special values', () {
      test('0x7fc00000 decodes to NaN', () {
        const bytes = [0x7f, 0xc0, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result.isNaN, true);
        _validateFloat32Decoding(bytes, result);
      });

      test('0x7f800000 decodes to +Infinity', () {
        const bytes = [0x7f, 0x80, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, double.infinity);
        _validateFloat32Decoding(bytes, result);
      });

      test('0xff800000 decodes to -Infinity', () {
        const bytes = [0xff, 0x80, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, double.negativeInfinity);
        _validateFloat32Decoding(bytes, result);
      });

      test('0x00000000 decodes to +0.0', () {
        const bytes = [0x00, 0x00, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, 0.0);
        _validateFloat32Decoding(bytes, result);
      });

      test('0x80000000 decodes to -0.0', () {
        const bytes = [0x80, 0x00, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, 0.0);
        expect(result.isNegative, true);
        _validateFloat32Decoding(bytes, result);
      });
    });

    group('Normal values', () {
      test('0x3f800000 decodes to 1.0', () {
        const bytes = [0x3f, 0x80, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, 1.0);
        _validateFloat32Decoding(bytes, result);
      });

      test('0xbf800000 decodes to -1.0', () {
        const bytes = [0xbf, 0x80, 0x00, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, -1.0);
        _validateFloat32Decoding(bytes, result);
      });

      test('0x47c35000 decodes to 100000.0', () {
        const bytes = [0x47, 0xc3, 0x50, 0x00];
        final result = fromFloat32Bytes(bytes);
        expect(result, 100000.0);
        _validateFloat32Decoding(bytes, result);
      });

      test('0x7f7fffff decodes to max float32', () {
        const bytes = [0x7f, 0x7f, 0xff, 0xff];
        final result = fromFloat32Bytes(bytes);
        expect(result, closeTo(3.4028234663852886e+38, 1e31));
        _validateFloat32Decoding(bytes, result);
      });
    });
  });

  group('Float32 round-trip tests', () {
    test('Values round-trip correctly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        2.0,
        0.5,
        100000.0,
        -100000.0,
        3.14159,
        -3.14159,
        1e10,
        1e-10,
        double.infinity,
        double.negativeInfinity,
      ];

      for (final value in testValues) {
        final bytes = toFloat32Bytes(value);
        final decoded = fromFloat32Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else if (value.isInfinite) {
          expect(decoded, value, reason: '$value should round-trip');
        } else {
          // Float32 has limited precision, so use closeTo for normal values
          expect(
            decoded,
            closeTo(value, value.abs() * 1e-6 + 1e-10),
            reason: '$value should round-trip',
          );
        }
        _validateFloat32Encoding(value, bytes);
      }
    });
  });

  group('isFloat32Lossless', () {
    test('Special values', () {
      expect(isFloat32Lossless(0.0), true);
      _validateIsFloat32Lossless(0.0, true);
      expect(isFloat32Lossless(-0.0), true);
      _validateIsFloat32Lossless(-0.0, true);
      expect(isFloat32Lossless(double.nan), true);
      _validateIsFloat32Lossless(double.nan, true);
      expect(isFloat32Lossless(double.infinity), true);
      _validateIsFloat32Lossless(double.infinity, true);
      expect(isFloat32Lossless(double.negativeInfinity), true);
      _validateIsFloat32Lossless(double.negativeInfinity, true);
    });

    test('Values that fit in float32', () {
      expect(isFloat32Lossless(1.0), true);
      _validateIsFloat32Lossless(1.0, true);
      expect(isFloat32Lossless(-1.0), true);
      _validateIsFloat32Lossless(-1.0, true);
      expect(isFloat32Lossless(100000.0), true);
      _validateIsFloat32Lossless(100000.0, true);
      expect(isFloat32Lossless(3.4028234663852886e+38), true);
      _validateIsFloat32Lossless(3.4028234663852886e+38, true);
    });

    test('Values that do not fit in float32', () {
      // Very large values
      expect(isFloat32Lossless(1e300), false);
      _validateIsFloat32Lossless(1e300, false);
      // Values with too much precision
      expect(isFloat32Lossless(1.0000000001), false);
      _validateIsFloat32Lossless(1.0000000001, false);
    });
  });

  group('Float64 (double-precision) encoding - toFloat64Bytes', () {
    group('Special values', () {
      test('NaN encodes correctly', () {
        final bytes = toFloat64Bytes(double.nan);
        expect(bytes.length, 8);
        _validateFloat64Encoding(double.nan, bytes);
      });

      test('+Infinity encodes to 0x7ff0000000000000', () {
        final result = toFloat64Bytes(double.infinity);
        expect(result, [0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(double.infinity, result);
      });

      test('-Infinity encodes to 0xfff0000000000000', () {
        final result = toFloat64Bytes(double.negativeInfinity);
        expect(result, [0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(double.negativeInfinity, result);
      });

      test('+0.0 encodes to all zeros', () {
        final result = toFloat64Bytes(0.0);
        expect(result, [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(0.0, result);
      });

      test('-0.0 encodes to 0x8000000000000000', () {
        final result = toFloat64Bytes(-0.0);
        expect(result, [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(-0.0, result);
      });
    });

    group('Normal values', () {
      test('1.0 encodes to 0x3ff0000000000000', () {
        final result = toFloat64Bytes(1.0);
        expect(result, [0x3f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(1.0, result);
      });

      test('-1.0 encodes to 0xbff0000000000000', () {
        final result = toFloat64Bytes(-1.0);
        expect(result, [0xbf, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        _validateFloat64Encoding(-1.0, result);
      });

      test('1e300 encodes correctly', () {
        final result = toFloat64Bytes(1e300);
        expect(result, [0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]);
        _validateFloat64Encoding(1e300, result);
      });
    });
  });

  group('Float64 (double-precision) decoding - fromFloat64Bytes', () {
    group('Special values', () {
      test('NaN decodes correctly', () {
        const bytes = [0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result.isNaN, true);
        _validateFloat64Decoding(bytes, result);
      });

      test('+Infinity decodes correctly', () {
        const bytes = [0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, double.infinity);
        _validateFloat64Decoding(bytes, result);
      });

      test('-Infinity decodes correctly', () {
        const bytes = [0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, double.negativeInfinity);
        _validateFloat64Decoding(bytes, result);
      });

      test('+0.0 decodes correctly', () {
        const bytes = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, 0.0);
        _validateFloat64Decoding(bytes, result);
      });

      test('-0.0 decodes correctly', () {
        const bytes = [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, 0.0);
        expect(result.isNegative, true);
        _validateFloat64Decoding(bytes, result);
      });
    });

    group('Normal values', () {
      test('1.0 decodes correctly', () {
        const bytes = [0x3f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, 1.0);
        _validateFloat64Decoding(bytes, result);
      });

      test('-1.0 decodes correctly', () {
        const bytes = [0xbf, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        final result = fromFloat64Bytes(bytes);
        expect(result, -1.0);
        _validateFloat64Decoding(bytes, result);
      });

      test('1e300 decodes correctly', () {
        const bytes = [0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c];
        final result = fromFloat64Bytes(bytes);
        expect(result, 1e300);
        _validateFloat64Decoding(bytes, result);
      });
    });
  });

  group('Float64 round-trip tests', () {
    test('All values round-trip exactly', () {
      final testValues = [
        0.0,
        -0.0,
        1.0,
        -1.0,
        2.0,
        0.5,
        1.1,
        3.14159265358979323846,
        1e300,
        1e-300,
        double.infinity,
        double.negativeInfinity,
        // Edge cases
        double.minPositive,
        double.maxFinite,
        -double.maxFinite,
      ];

      for (final value in testValues) {
        final bytes = toFloat64Bytes(value);
        final decoded = fromFloat64Bytes(bytes);
        if (value.isNaN) {
          expect(decoded.isNaN, true, reason: 'NaN should round-trip');
        } else {
          expect(decoded, value, reason: '$value should round-trip exactly');
        }
        _validateFloat64Encoding(value, bytes);
      }
    });
  });

  group('isFloat64Lossless', () {
    test('Always returns true', () {
      expect(isFloat64Lossless(0.0), true);
      expect(isFloat64Lossless(-0.0), true);
      expect(isFloat64Lossless(1.0), true);
      expect(isFloat64Lossless(double.nan), true);
      expect(isFloat64Lossless(double.infinity), true);
      expect(isFloat64Lossless(double.negativeInfinity), true);
      expect(isFloat64Lossless(1e300), true);
      expect(isFloat64Lossless(double.minPositive), true);
      expect(isFloat64Lossless(double.maxFinite), true);
    });
  });

  group('Cross-platform consistency (JS-specific bugs)', () {
    // These tests verify fixes for issues with the ieee754 package on JS
    test('Negative values encode correctly (sign bit handling)', () {
      // -4.0 was incorrectly encoded on JS due to setInt16 sign extension
      final encoded = toFloat16Bytes(-4.0);
      expect(encoded, [0xc4, 0x00]);
      expect(fromFloat16Bytes([0xc4, 0x00]), -4.0);
      _validateFloat16Encoding(-4.0, encoded);
    });

    test('Negative zero encodes correctly', () {
      // Negative zero was problematic on some platforms
      final bytes = toFloat16Bytes(-0.0);
      expect(bytes, [0x80, 0x00]);
      final decoded = fromFloat16Bytes(bytes);
      expect(decoded, 0.0);
      expect(decoded.isNegative, true);
      _validateFloat16Encoding(-0.0, bytes);
    });

    test('Large positive values with high bit set decode correctly', () {
      // Values like 65504 have high bit set in some representations
      const bytes = [0x7b, 0xff];
      final result = fromFloat16Bytes(bytes);
      expect(result, 65504.0);
      _validateFloat16Decoding(bytes, result);
    });

    test('Large negative values decode correctly', () {
      // -65504 was incorrectly decoded on JS
      const bytes = [0xfb, 0xff];
      final result = fromFloat16Bytes(bytes);
      expect(result, -65504.0);
      _validateFloat16Decoding(bytes, result);
    });
  });

  group('Edge cases', () {
    test('Byte arrays are the correct length', () {
      expect(toFloat16Bytes(1.0).length, 2);
      expect(toFloat32Bytes(1.0).length, 4);
      expect(toFloat64Bytes(1.0).length, 8);
    });

    test('Bytes are in big-endian order', () {
      // Float16: 1.0 = 0x3c00, so first byte should be 0x3c
      expect(toFloat16Bytes(1.0)[0], 0x3c);
      expect(toFloat16Bytes(1.0)[1], 0x00);

      // Float32: 1.0 = 0x3f800000, so first byte should be 0x3f
      expect(toFloat32Bytes(1.0)[0], 0x3f);
      expect(toFloat32Bytes(1.0)[3], 0x00);

      // Float64: 1.0 = 0x3ff0000000000000, so first byte should be 0x3f
      expect(toFloat64Bytes(1.0)[0], 0x3f);
      expect(toFloat64Bytes(1.0)[7], 0x00);
    });
  });
}
