/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('RFC Appendix A Diagnostics decoder tests -> ', () {
    test('0', () {
      final decoded = cbor.decode([0x00]);
      expect(decoded, CborSmallInt(0));
    });

    test('1', () {
      final decoded = cbor.decode([0x01]);
      expect(decoded, CborSmallInt(1));
    });

    test('10', () {
      final decoded = cbor.decode([0x0a]);
      expect(decoded, CborSmallInt(10));
    });

    test('23', () {
      final decoded = cbor.decode([0x17]);
      expect(decoded, CborSmallInt(23));
    });

    test('24', () {
      final decoded = cbor.decode([0x18, 0x18]);
      expect(decoded, CborSmallInt(24));
    });

    test('25', () {
      final decoded = cbor.decode([0x18, 0x19]);
      expect(decoded, CborSmallInt(25));
    });

    test('100', () {
      final decoded = cbor.decode([0x18, 0x64]);
      expect(decoded, CborSmallInt(100));
    });

    test('1000', () {
      final decoded = cbor.decode([0x19, 0x03, 0xE8]);
      expect(decoded, CborSmallInt(1000));
    });

    test('1000000', () {
      final decoded = cbor.decode([0x1a, 0x00, 0x0f, 0x42, 0x40]);
      expect(decoded, CborSmallInt(1000000));
    });

    test('1000000000000', () {
      final decoded =
          cbor.decode([0x1b, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00]);
      expect(decoded, CborSmallInt(1000000000000));
    });

    test('18446744073709551615', () {
      final decoded =
          cbor.decode([0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
      expect(decoded, CborInt(BigInt.parse('18446744073709551615')));
    });

    test('18446744073709551616', () {
      final decoded = cbor.decode(
          [0xc2, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      expect(decoded, CborBigInt(BigInt.parse('18446744073709551616')));
    });

    test('-18446744073709551616', () {
      final decoded =
          cbor.decode([0x3b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
      expect(decoded, CborInt(BigInt.parse('-18446744073709551616')));
    });

    test('-18446744073709551617', () {
      final decoded = cbor.decode(
          [0xc3, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      expect(decoded, CborInt(BigInt.parse('-18446744073709551617')));
    });

    test('-1', () {
      final decoded = cbor.decode([0x20]);
      expect(decoded, CborSmallInt(-1));
    });

    test('-10', () {
      final decoded = cbor.decode([0x29]);
      expect(decoded, CborSmallInt(-10));
    });

    test('-100', () {
      final decoded = cbor.decode([0x38, 0x63]);
      expect(decoded, CborSmallInt(-100));
    });

    test('-1000', () {
      final decoded = cbor.decode([0x39, 0x03, 0xE7]);
      expect(decoded, CborSmallInt(-1000));
    });

    test('0.0', () {
      final decoded = cbor.decode([0xF9, 0x00, 0x00]);
      expect(decoded, CborFloat(0.0));
    });

    test('-0.0', () {
      final decoded = cbor.decode([0xF9, 0x80, 0x00]);
      expect(decoded, CborFloat(-0.0));
    });

    test('1.0', () {
      final decoded = cbor.decode([0xF9, 0x3C, 0x00]);
      expect(decoded, CborFloat(1.0));
    });

    test('1.1', () {
      final decoded =
          cbor.decode([0xfb, 0x3f, 0xf1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a]);
      expect(decoded, CborFloat(1.1));
    });

    test('1.5', () {
      final decoded = cbor.decode([0xf9, 0x3e, 0x00]);
      expect(decoded, CborFloat(1.5));
    });

    test('65504.0', () {
      final decoded = cbor.decode([0xf9, 0x7b, 0xff]);
      expect(decoded, CborFloat(65504.0));
    });

    test('100000.0', () {
      final decoded = cbor.decode([0xfa, 0x47, 0xc3, 0x50, 0x00]);
      expect(decoded, CborFloat(100000.0));
    });

    test('3.4028234663852886e+38', () {
      final decoded = cbor.decode([0xfa, 0x7f, 0x7f, 0xff, 0xff]);
      expect(decoded, CborFloat(3.4028234663852886e+38));
    });

    test('1.0e+300', () {
      final decoded =
          cbor.decode([0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]);
      expect(decoded, CborFloat(1.0e+300));
    });

    test('5.960464477539063e-8', () {
      final decoded = cbor.decode([0xf9, 0x00, 0x01]);
      expect(decoded, CborFloat(5.960464477539063e-8));
    });

    test('0.00006103515625', () {
      final decoded = cbor.decode([0xf9, 0x04, 0x00]);
      expect(decoded, CborFloat(0.00006103515625));
    });

    test('-4.0', () {
      final decoded = cbor.decode([0xf9, 0xc4, 0x00]);
      expect(decoded, CborFloat(-4.0));
    });

    test('-4.1', () {
      final decoded =
          cbor.decode([0xfb, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66]);
      expect(decoded, CborFloat(-4.1));
    });

    test('Infinity half', () {
      final decoded = cbor.decode([0xf9, 0x7c, 0x00]);
      expect(decoded, CborFloat(double.infinity));
    });

    test('NaN half', () {
      final decoded = cbor.decode([0xf9, 0x7e, 0x00]);
      expect(decoded is CborFloat, true);
      expect((decoded as CborFloat).value, isNaN);
    });

    test('-Infinity half', () {
      final decoded = cbor.decode([0xf9, 0xfc, 0x00]);
      expect(decoded, CborFloat(double.negativeInfinity));
    });

    test('Infinity single', () {
      final decoded = cbor.decode([0xfa, 0x7f, 0x80, 0x00, 0x00]);
      expect(decoded, CborFloat(double.infinity));
    });

    test('NaN single', () {
      final decoded = cbor.decode([0xfa, 0x7f, 0xc0, 0x00, 0x00]);
      expect(decoded is CborFloat, true);
      expect((decoded as CborFloat).value, isNaN);
    });

    test('-Infinity single', () {
      final decoded = cbor.decode([0xfa, 0xff, 0x80, 0x00, 0x00]);
      expect(decoded, CborFloat(double.negativeInfinity));
    });

    test('Infinity double', () {
      final decoded =
          cbor.decode([0xfb, 0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      expect(decoded, CborFloat(double.infinity));
    });

    test('NaN double', () {
      final decoded =
          cbor.decode([0xfb, 0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      expect(decoded is CborFloat, true);
      expect((decoded as CborFloat).value, isNaN);
    });

    test('-Infinity double', () {
      final decoded =
          cbor.decode([0xfb, 0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
      expect(decoded, CborFloat(double.negativeInfinity));
    });

    test('false', () {
      final decoded = cbor.decode([0xf4]);
      expect(decoded, CborBool(false));
    });

    test('true', () {
      final decoded = cbor.decode([0xf5]);
      expect(decoded, CborBool(true));
    });

    test('null', () {
      final decoded = cbor.decode([0xf6]);
      expect(decoded, CborNull());
    });

    test('undefined', () {
      final decoded = cbor.decode([0xf7]);
      expect(decoded, CborUndefined());
    });

    test('Simple(16)', () {
      final decoded = cbor.decode([0xf0]);
      expect(decoded, CborSimpleValue(16));
    });

    test('Simple(24)', () {
      final decoded = cbor.decode([0xf8, 0x18]);
      expect(decoded, CborSimpleValue(24));
    });

    test('Simple(255)', () {
      final decoded = cbor.decode([0xf8, 0xff]);
      expect(decoded, CborSimpleValue(255));
    });

    test('Tag (0) Date Time', () {
      final decoded = cbor.decode([
        0xc0,
        0x74,
        0x32,
        0x30,
        0x31,
        0x33,
        0x2d,
        0x30,
        0x33,
        0x2d,
        0x32,
        0x31,
        0x54,
        0x32,
        0x30,
        0x3a,
        0x30,
        0x34,
        0x3a,
        0x30,
        0x30,
        0x5a
      ]);
      expect(decoded, CborDateTimeString.fromString('2013-03-21T20:04:00Z'));
      expect((decoded as CborDateTime).toDateTime(),
          DateTime.parse('2013-03-21T20:04:00Z'));
    });

    test('Tag (1) Int', () {
      final decoded = cbor.decode([0xc1, 0x1a, 0x51, 0x4b, 0x67, 0xb0]);
      expect(decoded, CborDateTimeInt.fromSecondsSinceEpoch(1363896240));
    });

    test('Tag (1) Float', () {
      final decoded = cbor
          .decode([0xc1, 0xfb, 0x41, 0xd4, 0x52, 0xd9, 0xec, 0x20, 0x00, 0x00]);
      expect(decoded, CborDateTimeFloat.fromSecondsSinceEpoch(1363896240.5));
    });

    test('Tag (23) multiple', () {
      final decoded = cbor.decode([0xd7, 0x44, 0x01, 0x02, 0x03, 0x04]);
      expect(
          decoded,
          CborBytes(
            [1, 2, 3, 4],
            tags: [CborTag.expectedConversionToBase16],
          ));
    });

    test('Tag (24) multiple', () {
      final decoded =
          cbor.decode([0xd8, 0x18, 0x45, 0x64, 0x49, 0x45, 0x54, 0x46]);
      expect(decoded,
          CborBytes([100, 73, 69, 84, 70], tags: [CborTag.encodedCborData]));
    });

    test('Tag (32) URI', () {
      final decoded = cbor.decode([
        0xd8,
        0x20,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ]);
      expect(decoded, CborUri.fromString('http://www.example.com'));
    });

    test('Empty single quotes', () {
      final decoded = cbor.decode([0x40]);
      expect(decoded, CborBytes([]));
    });

    test('4 bytes', () {
      final decoded = cbor.decode([0x44, 0x01, 0x02, 0x03, 0x04]);
      expect(decoded, CborBytes([01, 02, 03, 04]));
    });

    test('Empty double quotes', () {
      final decoded = cbor.decode([0x60]);
      expect(decoded, CborString(''));
    });

    test('a', () {
      final decoded = cbor.decode([0x61, 0x61]);
      expect(decoded, CborString('a'));
    });

    test('IETF', () {
      final decoded = cbor.decode([0x64, 0x49, 0x45, 0x54, 0x46]);
      expect(decoded, CborString('IETF'));
    });

    test('Quoted backslash', () {
      final decoded = cbor.decode([0x62, 0x22, 0x5c]);
      expect(decoded, CborString('"\\'));
    });

    test('Unicode ü', () {
      final decoded = cbor.decode([0x62, 0xc3, 0xbc]);
      expect(decoded, CborString('ü'));
    });

    test('Unicode 水', () {
      final decoded = cbor.decode([0x63, 0xe6, 0xb0, 0xb4]);
      expect(decoded, CborString('水'));
    });

    test('Unicode 𐅑', () {
      final decoded = cbor.decode([0x64, 0xf0, 0x90, 0x85, 0x91]);
      expect(decoded, CborString('𐅑'));
    });

    test('Array empty', () {
      final decoded = cbor.decode([0x80]);
      expect(decoded, []);
    });

    test('Array 1,2,3', () {
      final decoded = cbor.decode([0x83, 0x01, 0x02, 0x03]);
      expect(decoded, [CborSmallInt(1), CborSmallInt(2), CborSmallInt(3)]);
    });

    test('Array 1,2,3...25', () {
      final decoded = cbor.decode([
        0x98,
        0x19,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19
      ]);
      expect(decoded is CborList, true);
      if (decoded is CborList) {
        for (var i = 0; i < 25; i++) {
          expect(decoded[i], CborSmallInt(i + 1));
        }
      }
    });

    test('Nested array', () {
      final decoded =
          cbor.decode([0x83, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05]);
      expect(decoded, [
        CborSmallInt(1),
        [CborSmallInt(2), CborSmallInt(3)],
        [CborSmallInt(4), CborSmallInt(5)],
      ]);
    });

    test('Empty Map', () {
      final decoded = cbor.decode([0xa0]);
      expect(decoded, {});
    });

    test('{1: 2, 3: 4}', () {
      final decoded = cbor.decode([0xa2, 0x01, 0x02, 0x03, 0x04]);
      expect(decoded, {
        CborSmallInt(1): CborSmallInt(2),
        CborSmallInt(3): CborSmallInt(4),
      });
    });

    test('{"a": 1, "b": [2, 3]}', () {
      final decoded =
          cbor.decode([0xa2, 0x61, 0x61, 0x01, 0x61, 0x62, 0x82, 0x02, 0x03]);
      expect(decoded, {
        CborString('a'): CborSmallInt(1),
        CborString('b'): [CborSmallInt(2), CborSmallInt(3)],
      });
    });

    test('["a", {"b": "c"}]', () {
      final decoded =
          cbor.decode([0x82, 0x61, 0x61, 0xa1, 0x61, 0x62, 0x61, 0x63]);
      expect(decoded, [
        CborString('a'),
        {
          CborString('b'): CborString('c'),
        },
      ]);
    });

    test('{"a": "A", "b": "B", "c": "C", "d": "D", "e": "E"}', () {
      final decoded = cbor.decode([
        0xa5,
        0x61,
        0x61,
        0x61,
        0x41,
        0x61,
        0x62,
        0x61,
        0x42,
        0x61,
        0x63,
        0x61,
        0x43,
        0x61,
        0x64,
        0x61,
        0x44,
        0x61,
        0x65,
        0x61,
        0x45
      ]);
      expect(decoded, {
        CborString('a'): CborString('A'),
        CborString('b'): CborString('B'),
        CborString('c'): CborString('C'),
        CborString('d'): CborString('D'),
        CborString('e'): CborString('E'),
      });
    });

    test("(_ h'0102', h'030405')", () {
      final decoded =
          cbor.decode([0x5f, 0x42, 0x01, 0x02, 0x43, 0x03, 0x04, 0x05, 0xff]);
      expect(decoded, CborBytes([1, 2, 3, 4, 5]));
    });

    test('(_ "strea", "ming")', () {
      final decoded = cbor.decode([
        0x7f,
        0x65,
        0x73,
        0x74,
        0x72,
        0x65,
        0x61,
        0x64,
        0x6d,
        0x69,
        0x6e,
        0x67,
        0xff
      ]);
      expect(decoded, CborString('streaming'));
    });

    test('[_ ]', () {
      final decoded = cbor.decode([0x9f, 0xff]);
      expect(decoded, []);
    });

    test('[_ 1, [2, 3], [_4, 5]]', () {
      final decoded = cbor
          .decode([0x9f, 0x01, 0x82, 0x02, 0x03, 0x9f, 0x04, 0x05, 0xff, 0xff]);
      expect(decoded, [
        CborSmallInt(1),
        [CborSmallInt(2), CborSmallInt(3)],
        [CborSmallInt(4), CborSmallInt(5)],
      ]);
    });

    test('[_ 1, [2, 3], [4, 5]]', () {
      final decoded =
          cbor.decode([0x9f, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05, 0xff]);
      expect(decoded, [
        CborSmallInt(1),
        [CborSmallInt(2), CborSmallInt(3)],
        [CborSmallInt(4), CborSmallInt(5)],
      ]);
    });

    test('[1, [2, 3], [_ 4, 5]]', () {
      final decoded =
          cbor.decode([0x83, 0x01, 0x82, 0x02, 0x03, 0x9f, 0x04, 0x05, 0xff]);
      expect(decoded, [
        CborSmallInt(1),
        [CborSmallInt(2), CborSmallInt(3)],
        [CborSmallInt(4), CborSmallInt(5)],
      ]);
    });

    test('[1, [_ 2, 3], [4, 5]]', () {
      final decoded =
          cbor.decode([0x83, 0x01, 0x9f, 0x02, 0x03, 0xff, 0x82, 0x04, 0x05]);
      expect(decoded, [
        CborSmallInt(1),
        [CborSmallInt(2), CborSmallInt(3)],
        [CborSmallInt(4), CborSmallInt(5)],
      ]);
    });

    test('[_ 1, 2, 3 .. 25]', () {
      final decoded = cbor.decode([
        0x9f,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19,
        0xff
      ]);
      expect(decoded is CborList, true);

      if (decoded is CborList) {
        for (var i = 0; i < 25; i++) {
          expect(decoded[i], CborSmallInt(i + 1));
        }
      }
    });

    test('{_ "a":1, "b": [_ 2, 3]}', () {
      final decoded = cbor.decode(
          [0xbf, 0x61, 0x61, 0x01, 0x61, 0x62, 0x9f, 0x02, 0x03, 0xff, 0xff]);
      expect(decoded, {
        CborString('a'): CborSmallInt(1),
        CborString('b'): [CborSmallInt(2), CborSmallInt(3)],
      });
    });

    test('["a", {_ "b": "c"}]', () {
      final decoded =
          cbor.decode([0x82, 0x61, 0x61, 0xbf, 0x61, 0x62, 0x61, 0x63, 0xff]);
      expect(decoded, [
        CborString('a'),
        {
          CborString('b'): CborString('c'),
        },
      ]);
    });

    test('{_ "Fun": true, "Amt": -2}', () {
      final decoded = cbor.decode([
        0xbf,
        0x63,
        0x46,
        0x75,
        0x6e,
        0xf5,
        0x63,
        0x41,
        0x6d,
        0x74,
        0x21,
        0xff
      ]);
      expect(decoded, {
        CborString('Fun'): CborBool(true),
        CborString('Amt'): CborSmallInt(-2),
      });
    });
  });
}
