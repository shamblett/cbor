/*
 * Package : Cbor
 * Author : Alex Dochioiu <alex@vespr.xyz>
 * Date   : 19/06/2024
 * Copyright :  Alex Dochioiu
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group(
    "RationalNumber",
    () => {
      group('encoding tests', () {
        test('encode auto length', () {
          expect(
            cbor.encode(
              CborRationalNumber(
                numerator: CborInt(BigInt.from(1)),
                denominator: CborSmallInt(2),
                type: CborLengthType.auto,
              ),
            ),
            [0xd8, 0x1e, 0x82, 0x1, 0x2],
          );
        });

        test('encode definite length', () {
          expect(
            cbor.encode(
              CborRationalNumber(
                numerator: CborInt(BigInt.from(1)),
                denominator: CborSmallInt(2),
                type: CborLengthType.definite,
              ),
            ),
            [0xd8, 0x1e, 0x82, 0x1, 0x2],
          );
        });

        test('encode indefinite length', () {
          expect(
            cbor.encode(
              CborRationalNumber(
                numerator: CborInt(BigInt.from(1)),
                denominator: CborSmallInt(2),
                type: CborLengthType.indefinite,
              ),
            ),
            [0xd8, 0x1e, 0x9f, 0x1, 0x2, 0xff],
          );
        });
      }),
      group('decoding tests', () {
        test('auto length', () {
          expect(
            cbor.decode([0xd8, 0x1e, 0x82, 0x1, 0x2]),
            CborRationalNumber(
              numerator: CborInt(BigInt.from(1)),
              denominator: CborSmallInt(2),
              type: CborLengthType.auto,
            ),
          );
        });

        test('definite length', () {
          expect(
            cbor.decode([0xd8, 0x1e, 0x82, 0x1, 0x2]),
            CborRationalNumber(
              numerator: CborInt(BigInt.from(1)),
              denominator: CborSmallInt(2),
              type: CborLengthType.definite,
            ),
          );
        });

        test('indefinite length', () {
          expect(
            cbor.decode([0xd8, 0x1e, 0x9f, 0x1, 0x2, 0xff]),
            CborRationalNumber(
              numerator: CborInt(BigInt.from(1)),
              denominator: CborSmallInt(2),
              type: CborLengthType.indefinite,
            ),
          );
        });

        test('not CborRationalNumber when denominator is 0', () {
          expect(
            cbor.decode([0xd8, 0x1e, 0x9f, 0x1, 0x0, 0xff])
                is CborRationalNumber,
            false,
          );

          expect(
            cbor.decode([0xd8, 0x1e, 0x9f, 0x1, 0x0, 0xff]) is CborList,
            true,
          );
        });
      }),
    },
  );
}
