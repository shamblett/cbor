/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/simple.dart';
import 'package:test/test.dart';

void main() {
  group('RFC Appendix A Diagnostics encoder tests -> ', () {
    test('0', () {
      final encoded = cbor.encode(0);
      expect(encoded, [0x00]);
    });

    test('1', () {
      final encoded = cbor.encode(1);
      expect(encoded, [0x01]);
    });

    test('10', () {
      final encoded = cbor.encode(10);
      expect(encoded, [0x0A]);
    });

    test('23', () {
      final encoded = cbor.encode(23);
      expect(encoded, [0x17]);
    });

    test('24', () {
      final encoded = cbor.encode(24);
      expect(encoded, [0x18, 0x18]);
    });

    test('25', () {
      final encoded = cbor.encode(25);
      expect(encoded, [0x18, 0x19]);
    });

    test('100', () {
      final encoded = cbor.encode(100);
      expect(encoded, [0x18, 0x64]);
    });

    test('1000', () {
      final encoded = cbor.encode(1000);
      expect(encoded, [0x19, 0x03, 0xe8]);
    });

    test('1000000', () {
      final encoded = cbor.encode(1000000);
      expect(encoded, [0x1a, 0x00, 0x0f, 0x42, 0x40]);
    });

    test('1000000000000', () {
      final encoded = cbor.encode(1000000000000);
      expect(encoded, [0x1b, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00]);
    });

    test('18446744073709551615', () {
      final encoded = cbor.encode(BigInt.parse('18446744073709551615'));
      expect(encoded, [0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
    });

    test('18446744073709551616', () {
      final encoded = cbor.encode(BigInt.parse('18446744073709551616'));
      expect(
        encoded,
        [0xc2, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
      );
    });

    test('-18446744073709551616', () {
      final encoded = cbor.encode(BigInt.parse('-18446744073709551616'));
      expect(encoded, [0x3b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
    });

    test('-18446744073709551617', () {
      final encoded = cbor.encode(BigInt.parse('-18446744073709551617'));
      expect(
        encoded,
        [0xc3, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
      );
    });

    test('-1', () {
      final encoded = cbor.encode(-1);
      expect(encoded, [0x20]);
    });

    test('-10', () {
      final encoded = cbor.encode(-10);
      expect(encoded, [0x29]);
    });

    test('-100', () {
      final encoded = cbor.encode(-100);
      expect(encoded, [0x38, 0x63]);
    });

    test('-1000', () {
      final encoded = cbor.encode(-1000);
      expect(encoded, [0x39, 0x03, 0xe7]);
    });

    test('0.0', () {
      final encoded = cbor.encode(0.0);
      expect(encoded, [0xf9, 0x00, 0x00]);
    });

    test('-0.0', () {
      final encoded = cbor.encode(-0.0);
      expect(encoded, [0xf9, 0x80, 0x00]);
    });

    test('1.0', () {
      final encoded = cbor.encode(1.0);
      expect(encoded, [0xf9, 0x3c, 0x00]);
    });

    test('1.5', () {
      final encoded = cbor.encode(1.5);
      expect(encoded, [0xf9, 0x3e, 0x00]);
    });

    test('65504.0', () {
      final encoded = cbor.encode(65504.0);
      expect(encoded, [0xf9, 0x7b, 0xff]);
    });

    test('100000.0', () {
      final encoded = cbor.encode(100000.0);
      expect(encoded, [0xfa, 0x47, 0xc3, 0x50, 0x00]);
    });

    test('3.4028234663852886e+38', () {
      final encoded = cbor.encode(3.4028234663852886e+38);
      expect(encoded, [0xfa, 0x7f, 0x7f, 0xff, 0xff]);
    });

    test('1.0e+300', () {
      final encoded = cbor.encode(1.0e+300);
      expect(encoded, [0xfb, 0x7e, 0x37, 0xe4, 0x3c, 0x88, 0x00, 0x75, 0x9c]);
    });

    test('5.960464477539063e-8', () {
      final encoded = cbor.encode(5.960464477539063e-8);
      expect(encoded, [0xf9, 0x00, 0x01]);
    });

    test('0.00006103515625', () {
      final encoded = cbor.encode(0.00006103515625);
      expect(encoded, [0xf9, 0x04, 0x00]);
    });

    test('-4.0', () {
      final encoded = cbor.encode(-4.0);
      expect(encoded, [0xf9, 0xc4, 0x00]);
    });

    test('-4.1', () {
      final encoded = cbor.encode(-4.1);
      expect(encoded, [0xfb, 0xc0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66]);
    });

    test('Infinity', () {
      final encoded = cbor.encode(double.infinity);
      expect(encoded, [0xf9, 0x7c, 0x00]);
    });

    test('Nan', () {
      final encoded = cbor.encode(double.nan);
      expect(encoded, [0xf9, 0x7e, 0x00]);
    });

    test('-Infinity', () {
      final encoded = cbor.encode(double.negativeInfinity);
      expect(encoded, [0xf9, 0xfc, 0x00]);
    });

    test('False', () {
      final encoded = cbor.encode(false);
      expect(encoded, [0xf4]);
    });

    test('True', () {
      final encoded = cbor.encode(true);
      expect(encoded, [0xf5]);
    });

    test('Null', () {
      final encoded = cbor.encode(null);
      expect(encoded, [0xf6]);
    });

    test('Tag (0) Date Time', () {
      final encoded = cbor.encode(DateTime.parse('2013-03-21T20:04:00Z'));
      expect(encoded, [
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
        0x5a,
      ]);
    });

    test('Tag (1) Int', () {
      final encoded = cbor.encode(
        DateTime.fromMillisecondsSinceEpoch(
          1363896240000,
          isUtc: true,
        ),
        dateTimeEpoch: true,
      );
      expect(encoded, [0xc1, 0x1a, 0x51, 0x4b, 0x67, 0xb0]);
    });

    test('Tag (1) Float', () {
      final encoded = cbor.encode(
        DateTime.fromMillisecondsSinceEpoch(
          1363896240500,
          isUtc: true,
        ),
        dateTimeEpoch: true,
      );

      expect(
        encoded,
        [0xc1, 0xfb, 0x41, 0xd4, 0x52, 0xd9, 0xec, 0x20, 0x00, 0x00],
      );
    });

    test('Tag (32) URI', () {
      final encoded = cbor.encode(Uri.parse('http://www.example.com'));
      expect(encoded, [
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
        0x6d,
      ]);
    });

    test('Empty single quotes', () {
      final encoded = cbor.encode(Uint8List.fromList([]));
      expect(encoded, [0x40]);
    });

    test('4 bytes', () {
      final encoded = cbor.encode(Uint8List.fromList([0x1, 0x2, 0x3, 0x4]));
      expect(encoded, [0x44, 0x1, 0x2, 0x3, 0x4]);
    });

    test('Empty double quote', () {
      final encoded = cbor.encode('');
      expect(encoded, [0x60]);
    });

    test('"a"', () {
      final encoded = cbor.encode('a');
      expect(encoded, [0x61, 0x61]);
    });

    test('"IETF"', () {
      final encoded = cbor.encode('IETF');
      expect(encoded, [0x64, 0x49, 0x45, 0x54, 0x46]);
    });

    test('Quoted backslash', () {
      final encoded = cbor.encode('"\\');
      expect(encoded, [0x62, 0x22, 0x5c]);
    });

    test('Unicode ü', () {
      final encoded = cbor.encode('ü');
      expect(encoded, [0x62, 0xc3, 0xbc]);
    });

    test('Unicode 水', () {
      final encoded = cbor.encode('水');
      expect(encoded, [0x63, 0xe6, 0xb0, 0xb4]);
    });

    test('Unicode 𐅑', () {
      final encoded = cbor.encode('𐅑');
      expect(encoded, [0x64, 0xf0, 0x90, 0x85, 0x91]);
    });

    test('Array empty', () {
      final encoded = cbor.encode([]);
      expect(encoded, [0x80]);
    });

    test('Array 1,2,3', () {
      final encoded = cbor.encode([
        1,
        2,
        3,
      ]);
      expect(encoded, [0x83, 0x01, 0x02, 0x03]);
    });

    test('Array 1,[2,3],[4,5]', () {
      final encoded = cbor.encode([
        1,
        [2, 3],
        [4, 5],
      ]);
      expect(encoded, [0x83, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05]);
    });

    test('Array 1..25', () {
      final encoded = cbor.encode(List.generate(25, (index) => index + 1));
      expect(encoded, [
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
        0x19,
      ]);
    });

    test('{}', () {
      final encoded = cbor.encode({});
      expect(encoded, [0xa0]);
    });

    test('{1:2,3:4}', () {
      final encoded = cbor.encode({
        1: 2,
        3: 4,
      });
      expect(encoded, [0xa2, 0x01, 0x02, 0x03, 0x04]);
    });

    test('{a:1,b:[2,3]}', () {
      final encoded = cbor.encode({
        'a': 1,
        'b': [2, 3],
      });
      expect(encoded, [0xa2, 0x61, 0x61, 0x01, 0x061, 0x62, 0x82, 0x02, 0x03]);
    });

    test('[a, {b:c}]', () {
      final encoded = cbor.encode([
        'a',
        {
          'b': 'c',
        },
      ]);
      expect(encoded, [0x82, 0x61, 0x61, 0xa1, 0x61, 0x62, 0x61, 0x63]);
    });

    test('{"a": "A", "b": "B", "c": "C", "d": "D", "e": "E"}', () {
      final encoded =
          cbor.encode({'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D', 'e': 'E'});
      expect(encoded, [
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
        0x45,
      ]);
    });
  });
}
