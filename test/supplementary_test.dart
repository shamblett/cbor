/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('Known patterns', () {
    test('Pattern 1  -> ', () {
      final encoded = cbor.encode(CborMap({
        CborString('p16'): CborSmallInt(16),
        CborString('uni'): CborString('\u901A\u8A0A\u9023\u63A5\u57E0 (COM1)'),
        CborString('n1'): CborSmallInt(-1),
        CborString('ascii'): CborString('hello'),
        CborString('nil'): CborNull(),
        CborString('empty_arr'): CborList([]),
        CborString('p65535'): CborSmallInt(65535),
        CborString('bin'): CborBytes([0x31, 0x32, 0x55]),
        CborString('n2G'): CborSmallInt(-2147483648),
        CborString('p1'): CborSmallInt(1),
        CborString('n65535'): CborSmallInt(-65535),
        CborString('n16'): CborSmallInt(-16),
        CborString('zero'): CborSmallInt(0),
        CborString('arr'):
            CborList([CborSmallInt(1), CborSmallInt(2), CborSmallInt(3)]),
        CborString('obj'): CborMap({CborString('foo'): CborString('bar')}),
        CborString('bfalse'): CborBool(false),
        CborString('p255'): CborSmallInt(255),
        CborString('p2G'): CborSmallInt(2147483648),
        CborString('n255'): CborSmallInt(-255),
        CborString('btrue'): CborBool(true),
      }));

      expect(encoded, [
        0xB4,
        0x63,
        0x70,
        0x31,
        0x36,
        0x10,
        0x63,
        0x75,
        0x6E,
        0x69,
        0x76,
        0xE9,
        0x80,
        0x9A,
        0xE8,
        0xA8,
        0x8A,
        0xE9,
        0x80,
        0xA3,
        0xE6,
        0x8E,
        0xA5,
        0xE5,
        0x9F,
        0xA0,
        0x20,
        0x28,
        0x43,
        0x4F,
        0x4D,
        0x31,
        0x29,
        0x62,
        0x6E,
        0x31,
        0x20,
        0x65,
        0x61,
        0x73,
        0x63,
        0x69,
        0x69,
        0x65,
        0x68,
        0x65,
        0x6C,
        0x6C,
        0x6F,
        0x63,
        0x6E,
        0x69,
        0x6C,
        0xF6,
        0x69,
        0x65,
        0x6D,
        0x70,
        0x74,
        0x79,
        0x5F,
        0x61,
        0x72,
        0x72,
        0x80,
        0x66,
        0x70,
        0x36,
        0x35,
        0x35,
        0x33,
        0x35,
        0x19,
        0xFF,
        0xFF,
        0x63,
        0x62,
        0x69,
        0x6E,
        0x43,
        0x31,
        0x32,
        0x55,
        0x63,
        0x6E,
        0x32,
        0x47,
        0x3A,
        0x7F,
        0xFF,
        0xFF,
        0xFF,
        0x62,
        0x70,
        0x31,
        0x01,
        0x66,
        0x6E,
        0x36,
        0x35,
        0x35,
        0x33,
        0x35,
        0x39,
        0xFF,
        0xFE,
        0x63,
        0x6E,
        0x31,
        0x36,
        0x2F,
        0x64,
        0x7A,
        0x65,
        0x72,
        0x6F,
        0x00,
        0x63,
        0x61,
        0x72,
        0x72,
        0x83,
        0x01,
        0x02,
        0x03,
        0x63,
        0x6F,
        0x62,
        0x6A,
        0xA1,
        0x63,
        0x66,
        0x6F,
        0x6F,
        0x63,
        0x62,
        0x61,
        0x72,
        0x66,
        0x62,
        0x66,
        0x61,
        0x6C,
        0x73,
        0x65,
        0xF4,
        0x64,
        0x70,
        0x32,
        0x35,
        0x35,
        0x18,
        0xFF,
        0x63,
        0x70,
        0x32,
        0x47,
        0x1A,
        0x80,
        0x00,
        0x00,
        0x00,
        0x64,
        0x6E,
        0x32,
        0x35,
        0x35,
        0x38,
        0xFE,
        0x65,
        0x62,
        0x74,
        0x72,
        0x75,
        0x65,
        0xF5
      ]);
    });
  });

  group('Error handling', () {
    test('No input', () {
      expect(() => cbor.decode([]), throwsException);
    });

    test('Random bytes', () {
      expect(() => cbor.decode([0xcd, 0xfe, 0x00]), throwsException);
    });

    test('Premature termination', () {
      expect(
        () => cbor.decode([0x44, 0x01, 0x02, 0x03]),
        throwsException,
      );
    });

    test('Cyclic reference', () {
      final list = CborList([]);
      list.add(list);

      expect(() => cbor.encode(list), throwsA(isA<CborCyclicError>()));
    });
  });

  group('Bignum', () {
    test('Big Num Positive', () {
      final test = BigInt.from(922337203685477580767.0);
      expect(cbor.decode(cbor.encode(CborBigInt(test))).toObject(), test);
    });

    test('Big Num Negative', () {
      final test = BigInt.from(-922337203685477580767.0);
      expect(cbor.decode(cbor.encode(CborBigInt(test))).toObject(), test);
    });
  });

  group('constructor', () {
    test('Test 1', () {
      expect(
        CborValue(
          [
            {'a': 'b'},
            null,
            [1, 2, 3],
            Uint8List.fromList([1, 2, 3]),
            DateTime.fromMillisecondsSinceEpoch(2000),
          ],
          dateTimeEpoch: true,
        ),
        CborList([
          CborMap({
            CborString('a'): CborString('b'),
          }),
          CborNull(),
          CborList([CborSmallInt(1), CborSmallInt(2), CborSmallInt(3)]),
          CborBytes([1, 2, 3]),
          CborDateTimeInt.fromSecondsSinceEpoch(2),
        ]),
      );
    });
  });

  group('toObject', () {
    test('Test 1', () {
      expect(
          CborValue(
            [
              {'a': 'b'},
              null,
              [1, 2, 3],
              Uint8List.fromList([1, 2, 3]),
              DateTime.fromMillisecondsSinceEpoch(2000),
            ],
            dateTimeEpoch: true,
          ).toObject(),
          [
            {'a': 'b'},
            null,
            [1, 2, 3],
            [1, 2, 3],
            DateTime.fromMillisecondsSinceEpoch(2000).toUtc(),
          ]);
    });
  });
}
