/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/02/2026
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('cborPrettyPrint', () {
    test('positive integer', () {
      final value = CborSmallInt(42);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('18 2a (int 42)'));
    });

    test('negative integer', () {
      final value = CborSmallInt(-42);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('38 29 (int -42)'));
    });

    test('large integer', () {
      final value = CborInt(BigInt.parse('18446744073709551615'));
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals('1b ff ff ff ff ff ff ff ff (int 18446744073709551615)'),
      );
    });

    test('bytes', () {
      final value = CborBytes([1, 2, 3]);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('43 1 2 3 (bytes)'));
    });

    test('indefinite length bytes', () {
      final value = CborBytes.indefinite([
        [1],
        [2, 3],
      ]);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          '5f (indefinite length bytes)\n'
          '  41 1 (bytes)\n'
          '  42 2 3 (bytes)\n'
          '  ff (break)',
        ),
      );
    });

    test('string', () {
      final value = CborString('hello');
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('65 68 65 6c 6c 6f (string "hello")'));
    });

    test('indefinite length string', () {
      final value = CborString.indefinite(['hel', 'lo']);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          '7f (indefinite length string)\n'
          '  63 68 65 6c (string "hel")\n'
          '  62 6c 6f (string "lo")\n'
          '  ff (break)',
        ),
      );
    });

    test('array', () {
      final value = CborList([CborSmallInt(1), CborSmallInt(2)]);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          '82 (array length 2)\n'
          '  1 (int 1)\n'
          '  2 (int 2)',
        ),
      );
    });

    test('indefinite length array', () {
      final value = CborList([
        CborSmallInt(1),
        CborSmallInt(2),
      ], type: CborLengthType.indefinite);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          '9f (indefinite length array)\n'
          '  1 (int 1)\n'
          '  2 (int 2)\n'
          '  ff (break)',
        ),
      );
    });

    test('map', () {
      final value = CborMap({CborSmallInt(1): CborString('one')});
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          'a1 (map length 1)\n'
          '  1 (int 1)\n'
          '  63 6f 6e 65 (string "one")',
        ),
      );
    });

    test('indefinite length map', () {
      final value = CborMap({
        CborSmallInt(1): CborString('one'),
      }, type: CborLengthType.indefinite);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          'bf (indefinite length map)\n'
          '  1 (int 1)\n'
          '  63 6f 6e 65 (string "one")\n'
          '  ff (break)',
        ),
      );
    });

    test('tag', () {
      final value = CborDateTimeString(
        DateTime.parse('2022-01-01T00:00:00.000Z'),
      );
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          'c0 (tag 0)\n'
          '74 32 30 32 32 2d 30 31 2d 30 31 54 30 30 3a 30 30 3a 30 30 5a (string "2022-01-01T00:00:00Z")',
        ),
      );
    });

    test('null', () {
      final value = CborNull();
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('f6 (null)'));
    });

    test('true', () {
      final value = CborBool(true);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('f5 (true)'));
    });

    test('false', () {
      final value = CborBool(false);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('f4 (false)'));
    });

    test('undefined', () {
      final value = CborUndefined();
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('f7 (undefined)'));
    });

    test('simple float (double)', () {
      final value = CborFloat(3.14);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('fb 40 9 1e b8 51 eb 85 1f (3.14)'));
    });

    test('simple float (half and single)', () {
      final bytes = [
        0xf9, 0x3e, 0x00, // half precision 1.5
        0xfa, 0x3f, 0xc0, 0x00, 0x00, // single precision 1.5
      ];
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          'f9 3e 0 (1.5)\n'
          'fa 3f c0 0 0 (1.5)',
        ),
      );
    });

    test('simple value', () {
      final value = CborSimpleValue(200);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(pretty.trim(), equals('f8 c8 (simple 200)'));
    });

    test('indent setting', () {
      final value = CborMap({CborSmallInt(1): CborString('one')});
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes, indent: 4);
      expect(
        pretty.trim(),
        equals(
          'a1 (map length 1)\n'
          '    1 (int 1)\n'
          '    63 6f 6e 65 (string "one")',
        ),
      );
    });

    test('nested map', () {
      final value = CborMap({
        CborSmallInt(1): CborMap({CborSmallInt(2): CborString('two')}),
      });
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          'a1 (map length 1)\n'
          '  1 (int 1)\n'
          '  a1 (map length 1)\n'
          '    2 (int 2)\n'
          '    63 74 77 6f (string "two")',
        ),
      );
    });

    test('nested list', () {
      final value = CborList([
        CborList([CborSmallInt(1), CborSmallInt(2)]),
        CborString('three'),
      ]);
      final bytes = cbor.encode(value);
      final pretty = cborPrettyPrint(bytes);
      expect(
        pretty.trim(),
        equals(
          '82 (array length 2)\n'
          '  82 (array length 2)\n'
          '    1 (int 1)\n'
          '    2 (int 2)\n'
          '  65 74 68 72 65 65 (string "three")',
        ),
      );
    });
  });
}
