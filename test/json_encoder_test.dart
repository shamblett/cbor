/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

// Platform detection: on JS (dart2js), integer-valued doubles (0.0, 1.0, etc.)
// are indistinguishable from integers and get encoded as CBOR integers.
// Note: This does NOT apply to WASM (dart2wasm), which handles this correctly.
// Using `identical(0, 0.0)` which returns true only on JS where int/double are same.
final bool kIsJs = identical(0, 0.0);

String encode(Object? input) {
  return const CborJsonEncoder().convert(CborValue(input));
}

void main() {
  group('RFC Appendix A Diagnostics encoder tests -> ', () {
    test('0', () {
      expect(encode(0), '0');
    });

    test('100', () {
      expect(encode(100), '100');
    });

    test('18446744073709551615', () {
      expect(
        encode(BigInt.parse('18446744073709551615')),
        '"FFFFFFFFFFFFFFFF"',
      );
    });

    test('18446744073709551616', () {
      expect(
        encode(BigInt.parse('18446744073709551616')),
        '"010000000000000000"',
      );
    });

    test('-18446744073709551616', () {
      expect(
        encode(BigInt.parse('-18446744073709551616')),
        '"~FFFFFFFFFFFFFFFF"',
      );
    });

    test('-18446744073709551617', () {
      expect(
        encode(BigInt.parse('-18446744073709551617')),
        '"~010000000000000000"',
      );
    });

    test('-1', () {
      expect(encode(-1), '-1');
    });

    test('0.0', () {
      if (kIsJs) {
        // On JS, 0.0 is indistinguishable from 0
        // because JSON.stringify(0.0) returns '0' on JS.
        expect(encode(0.0), '0');
        expect(const CborJsonEncoder().convert(CborFloat(0.0)), '0');
      } else {
        expect(encode(0.0), '0.0');
        expect(const CborJsonEncoder().convert(CborFloat(0.0)), '0.0');
      }
    });

    test('-0.0', () {
      expect(encode(-0.0), '-0.0');
    });

    test('1.0', () {
      if (kIsJs) {
        // On JS, 1.0 is indistinguishable from 1
        expect(encode(1.0), '1');
        expect(const CborJsonEncoder().convert(CborFloat(1.0)), '1');
      } else {
        expect(encode(1.0), '1.0');
        expect(const CborJsonEncoder().convert(CborFloat(1.0)), '1.0');
      }
    });

    test('1.5', () {
      expect(encode(1.5), '1.5');
    });

    test('65504.0', () {
      if (kIsJs) {
        // On JS, 65504.0 is indistinguishable from 65504
        expect(encode(65504.0), '65504');
        expect(const CborJsonEncoder().convert(CborFloat(65504.0)), '65504');
      } else {
        expect(encode(65504.0), '65504.0');
        expect(const CborJsonEncoder().convert(CborFloat(65504.0)), '65504.0');
      }
    });

    test('100000.0', () {
      if (kIsJs) {
        // On JS, 100000.0 is indistinguishable from 100000
        expect(encode(100000.0), '100000');
        expect(const CborJsonEncoder().convert(CborFloat(100000.0)), '100000');
      } else {
        expect(encode(100000.0), '100000.0');
        expect(
          const CborJsonEncoder().convert(CborFloat(100000.0)),
          '100000.0',
        );
      }
    });

    test('3.4028234663852886e+38', () {
      expect(encode(3.4028234663852886e+38), '3.4028234663852886e+38');
    });

    test('1.0e+300', () {
      expect(encode(1.0e+300), '1e+300');
    });

    test('5.960464477539063e-8', () {
      expect(encode(5.960464477539063e-8), '5.960464477539063e-8');
    });

    test('0.00006103515625', () {
      expect(encode(0.00006103515625), '0.00006103515625');
    });

    test('Infinity', () {
      expect(encode(double.infinity), 'null');
    });

    test('Nan', () {
      expect(encode(double.nan), 'null');
    });

    test('-Infinity', () {
      expect(encode(double.negativeInfinity), 'null');
    });

    test('False', () {
      expect(encode(false), 'false');
    });

    test('True', () {
      expect(encode(true), 'true');
    });

    test('Null', () {
      expect(encode(null), 'null');
    });

    test('Empty single quotes', () {
      expect(encode(Uint8List.fromList([])), '""');
    });

    test('4 bytes', () {
      expect(encode(Uint8List.fromList([0x1, 0x2, 0x3, 0x4])), '"01020304"');
    });

    test('Quoted backslash', () {
      expect(encode('\\'), '"\\\\"');
    });

    test('New line', () {
      expect(encode('\n'), '"\\n"');
    });

    test('Unicode ü', () {
      expect(encode('ü'), '"ü"');
    });

    test('Unicode 水', () {
      expect(encode('水'), '"水"');
    });

    test('Array empty', () {
      expect(encode([]), '[]');
    });

    test('Array 1,2,3', () {
      expect(encode([1, 2, 3]), '[1,2,3]');
    });

    test('Array 1,[2,3],[4,5]', () {
      expect(
        encode([
          1,
          [2, 3],
          [4, 5],
        ]),
        '[1,[2,3],[4,5]]',
      );
    });

    test('{}', () {
      expect(encode({}), '{}');
    });

    test('{a:1,b:[2,3]}', () {
      expect(
        encode({
          'a': 1,
          'b': [2, 3],
        }),
        '{"a":1,"b":[2,3]}',
      );
    });

    test('[a, {b:c}]', () {
      expect(
        encode([
          'a',
          {'b': 'c'},
        ]),
        '["a",{"b":"c"}]',
      );
    });
  });
}
