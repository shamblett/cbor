/*
 * Package : Cbor
 * Author : Alex Dochioiu <alex@vespr.xyz>
 * Date   : 19/06/2024
 * Copyright :  Alex Dochioiu
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group("Int Numbers Test", () {
    final numbersToTest = [
      BigInt.parse("0"),
      BigInt.parse("1"),
      BigInt.parse("2656159029"),
      BigInt.parse("4294967295"),
      BigInt.parse("4294967296"),
      BigInt.parse("4294967299"),
      BigInt.parse("5294967590"),
      BigInt.parse("91234567890"),
      BigInt.parse("912345678901234567890"),
    ];

    group("positive numbers", () {
      for (final number in numbersToTest) {
        test(number.toString(), () {
          final cborInt = CborInt(number);
          final serialized = cborEncode(cborInt);
          final deserialized = cborDecode(serialized);
          expect(cborInt.toBigInt(), number);
          expect(deserialized, isA<CborInt>());
          expect((deserialized as CborInt).toBigInt(), number);
        });
      }
    });

    group("negative numbers", () {
      for (final positiveNumber in numbersToTest) {
        final number = BigInt.zero - positiveNumber;
        test(number.toString(), () {
          final cborInt = CborInt(number);
          final serialized = cborEncode(cborInt);
          final deserialized = cborDecode(serialized);
          expect(cborInt.toBigInt(), number);
          expect(deserialized, isA<CborInt>());
          expect((deserialized as CborInt).toBigInt(), number);
        });
      }
    });
  });
}
