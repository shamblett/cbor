import 'dart:convert';
import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('multi_dimensional_array', () {
    test('CborMultiDimensionalArray fromTypedArray', () {
      final typedArray = CborUint8Array.fromList([1, 2, 3, 4, 5, 6]);
      final arr = CborMultiDimensionalArray.fromTypedArray([2, 3], typedArray);
      expect(arr.dimensions, [2, 3]);
      expect(arr.data, isA<CborUint8Array>());
      expect(
        arr.toObject(),
        equals([
          [2, 3],
          [1, 2, 3, 4, 5, 6],
        ]),
      );
      expect(arr.toJson(), isNotNull);
    });

    test('CborMultiDimensionalArray fromValues', () {
      final arr = CborMultiDimensionalArray.fromValues(
        [2, -2],
        [CborSmallInt(1), CborSmallInt(2)],
      );
      expect(arr.dimensions, [2, -2]);
      expect(arr.data, isA<CborList>());
      expect(
        arr.toObject(),
        equals([
          [2, -2],
          [1, 2],
        ]),
      );
      expect(
        arr.toJson(),
        equals([
          [2, -2],
          [1, 2],
        ]),
      );

      final bytes = cbor.encode(arr);
      expect(bytes, isNotEmpty);

      final decoded = cbor.decode(bytes);
      expect(decoded.tags, contains(CborTag.multiDimensionalArray));
    });
  });

  group('simple_value', () {
    test('CborSimpleValue basics', () {
      const val = CborSimpleValue(10, tags: [123]);
      expect(val.hashCode, const CborSimpleValue(10, tags: [123]).hashCode);
      expect(val.toString(), '10');
      expect(val == const CborSimpleValue(10, tags: [123]), isTrue);
      expect(val == const CborSimpleValue(11, tags: [123]), isFalse);

      final sinkObj = val.toObject();
      expect(sinkObj, 10);

      final sinkJson = val.toJson();
      expect(sinkJson, isNull);
    });

    test('CborUndefined toJson', () {
      const undef = CborUndefined();
      expect(undef.toJson(), isNull);
    });
  });

  group('string', () {
    test('CborString indefinite length', () {
      final indefiniteString = CborString.indefinite(
        ['hello', 'world'],
        tags: [100],
      );
      expect(indefiniteString.utf8Bytes, utf8.encode('helloworld'));
      expect(
        indefiniteString.hashCode,
        CborString.indefinite(['hello', 'world'], tags: [100]).hashCode,
      );
      expect(
        indefiniteString ==
            CborString.indefinite(['hello', 'world'], tags: [100]),
        isTrue,
      );
      expect(indefiniteString.toString(allowMalformed: true), 'helloworld');
      expect(indefiniteString.toJson(), 'helloworld');

      final encoded = cbor.encode(indefiniteString);
      expect(encoded, isNotEmpty);
    });

    test('CborEncodeIndefiniteLengthString', () {
      final encodeIndef = CborEncodeIndefiniteLengthString(['a', 'b']);
      expect(encodeIndef.toObject(), 'ab');
      expect(encodeIndef.toJson(), 'ab');
      final encoded = cbor.encode(encodeIndef);
      expect(encoded, isNotEmpty);
    });

    test('CborEncodeDefiniteLengthString', () {
      final encodeDef = CborEncodeDefiniteLengthString(CborString('test'));
      expect(encodeDef.toObject(), 'test');
      expect(encodeDef.toJson(), 'test');
      final encoded = cbor.encode(encodeDef);
      expect(encoded, isNotEmpty);
    });

    test('CborBase64Url', () {
      final base64Url = CborBase64Url.encode([1, 2, 3]);
      expect(base64Url.toObject(decodeBase64: true), [1, 2, 3]);
      expect(base64Url.toObject(decodeBase64: false), base64Url.toString());

      final fromStr = CborBase64Url.fromString('AQID');
      expect(fromStr.decode(), [1, 2, 3]);

      final fromUtf8 = CborBase64Url.fromUtf8(utf8.encode('AQID'));
      expect(fromUtf8.decode(), [1, 2, 3]);
    });

    test('CborRegex and CborMime fromUtf8', () {
      final regex = CborRegex.fromUtf8(utf8.encode('.*'));
      expect(regex.toString(), '.*');

      final mime = CborMime.fromUtf8(utf8.encode('text/plain'));
      expect(mime.toString(), 'text/plain');
    });

    test('CborDateTimeString toObject without parse', () {
      final dtStr = CborDateTimeString(DateTime(2022));
      expect(dtStr.toObject(parseDateTime: false), dtStr.toString());
    });
  });

  group('bytes', () {
    test('CborBytes basics', () {
      final bytesBase64 = CborBytes(
        [1, 2, 3],
        tags: [CborTag.expectedConversionToBase64],
      );
      expect(
        bytesBase64.bytesList,
        equals([
          [1, 2, 3],
        ]),
      );
      expect(bytesBase64.toString(), [1, 2, 3].toString());
      expect(bytesBase64.toJson(), base64.encode([1, 2, 3]));

      final bytesBase64Url = CborBytes(
        [1, 2, 3],
        tags: [CborTag.expectedConversionToBase64Url],
      );
      expect(
        bytesBase64Url.toJson(),
        base64Url.encode([1, 2, 3]).replaceAll('=', ''),
      );
    });

    test('CborBytes indefinite length', () {
      final indefBytes = CborBytes.indefinite(
        [
          [1, 2],
          [3],
        ],
        tags: [CborTag.expectedConversionToBase64Url],
      );
      expect(indefBytes.bytes, [1, 2, 3]);
      expect(indefBytes.hashCode, isA<int>());
      expect(
        indefBytes ==
            CborBytes.indefinite(
              [
                [1, 2],
                [3],
              ],
              tags: [CborTag.expectedConversionToBase64Url],
            ),
        isTrue,
      );
      expect(indefBytes.toString(), [1, 2, 3].toString());
      expect(indefBytes.toObject(), [1, 2, 3]);

      expect(
        indefBytes.toJson(),
        base64Url.encode([1, 2, 3]).replaceAll('=', ''),
      );

      final indefBytesBase64 = CborBytes.indefinite(
        [
          [1, 2],
          [3],
        ],
        tags: [CborTag.expectedConversionToBase64],
      );
      expect(indefBytesBase64.toJson(), base64.encode([1, 2, 3]));

      final encoded = cbor.encode(indefBytes);
      expect(encoded, isNotEmpty);
    });
  });

  group('list', () {
    test('CborList.generate', () {
      final l = CborList.generate(3, (i) => CborSmallInt(i));
      expect(l.length, 3);
      expect(l[0], CborSmallInt(0));
      expect(l[1], CborSmallInt(1));
    });

    test('CborList cyclic', () {
      final l = CborList.of([]);
      l.add(l);
      expect(() => l.toObject(), throwsA(isA<CborCyclicError>()));
      expect(() => l.toJson(), throwsA(isA<CborCyclicError>()));
    });

    test('CborEncodeDefiniteLengthList', () {
      final defList = CborEncodeDefiniteLengthList(CborList([CborSmallInt(1)]));
      expect(defList.toJson(), equals([1]));
      expect(defList.toObject(), equals([1]));
    });

    test('CborEncodeIndefiniteLengthList', () {
      final indefList = CborEncodeIndefiniteLengthList(
        CborList([CborSmallInt(1)]),
      );
      expect(indefList.toJson(), equals([1]));
      expect(indefList.toObject(), equals([1]));
    });

    test('CborDecimalFraction', () {
      final decFrac = CborDecimalFraction(
        exponent: CborSmallInt(-2),
        mantissa: CborSmallInt(123),
      );
      expect(decFrac.toObject(), equals([-2, BigInt.from(123)]));
      expect(decFrac.toJson(), equals([-2, 123]));

      final encDef = cbor.encode(
        CborDecimalFraction(
          exponent: CborSmallInt(-2),
          mantissa: CborSmallInt(123),
          type: CborLengthType.definite,
        ),
      );
      expect(encDef, isNotEmpty);

      final encIndef = cbor.encode(
        CborDecimalFraction(
          exponent: CborSmallInt(-2),
          mantissa: CborSmallInt(123),
          type: CborLengthType.indefinite,
        ),
      );
      expect(encIndef, isNotEmpty);
    });

    test('CborRationalNumber', () {
      final rational = CborRationalNumber(
        numerator: CborSmallInt(1),
        denominator: CborSmallInt(3),
      );
      expect(rational.toObject(), equals([BigInt.from(1), BigInt.from(3)]));
      expect(rational.toJson(), equals([1, 3]));

      final encIndef = cbor.encode(
        CborRationalNumber(
          numerator: CborSmallInt(1),
          denominator: CborSmallInt(3),
          type: CborLengthType.indefinite,
        ),
      );
      expect(encIndef, isNotEmpty);
    });

    test('CborBigFloat', () {
      final bigFloat = CborBigFloat(
        exponent: CborSmallInt(-2),
        mantissa: CborSmallInt(123),
      );
      expect(bigFloat.toObject(), equals([-2, BigInt.from(123)]));
      expect(bigFloat.toJson(), equals([-2, 123]));

      final encIndef = cbor.encode(
        CborBigFloat(
          exponent: CborSmallInt(-2),
          mantissa: CborSmallInt(123),
          type: CborLengthType.indefinite,
        ),
      );
      expect(encIndef, isNotEmpty);
    });
  });
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
