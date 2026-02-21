/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 21/02/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';
import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('CborTypedArray', () {
    test('CborUint8Array', () {
      final arr = CborUint8Array.fromList([1, 2, 255]);
      expect(arr.tags, equals([CborTag.uint8Array]));
      expect(arr.toObject(), isA<Uint8List>());
      expect(arr.toObject(), equals([1, 2, 255]));
    });

    test('CborUint8ClampedArray', () {
      final arr = CborUint8ClampedArray.fromList([1, 2, 256, -1]);
      expect(arr.tags, equals([CborTag.uint8ArrayClamped]));
      expect(arr.toObject(), isA<Uint8ClampedList>());
      expect(arr.toObject(), equals([1, 2, 255, 0]));
    });

    test('CborUint16BigEndianArray', () {
      final arr = CborUint16BigEndianArray.fromList([1, 2, 65535]);
      expect(arr.tags, equals([CborTag.uint16ArrayBE]));
      expect(arr.toObject(), isA<Uint16List>());
      expect(arr.toObject(), equals([1, 2, 65535]));

      expect(
        () => CborUint16BigEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborUint16LittleEndianArray', () {
      final arr = CborUint16LittleEndianArray.fromList([1, 2, 65535]);
      expect(arr.tags, equals([CborTag.uint16ArrayLE]));
      expect(arr.toObject(), isA<Uint16List>());
      expect(arr.toObject(), equals([1, 2, 65535]));

      expect(
        () => CborUint16LittleEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborUint32BigEndianArray', () {
      final arr = CborUint32BigEndianArray.fromList([1, 2, 4294967295]);
      expect(arr.tags, equals([CborTag.uint32ArrayBE]));
      expect(arr.toObject(), isA<Uint32List>());
      expect(arr.toObject(), equals([1, 2, 4294967295]));

      expect(
        () => CborUint32BigEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborUint32LittleEndianArray', () {
      final arr = CborUint32LittleEndianArray.fromList([1, 2, 4294967295]);
      expect(arr.tags, equals([CborTag.uint32ArrayLE]));
      expect(arr.toObject(), isA<Uint32List>());
      expect(arr.toObject(), equals([1, 2, 4294967295]));

      expect(
        () => CborUint32LittleEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborUint64BigEndianArray', () {
      final arr = CborUint64BigEndianArray.fromList([
        1,
        2,
        9223372036854775807,
      ]);
      expect(arr.tags, equals([CborTag.uint64ArrayBE]));
      expect(
        arr.toObject(),
        isA<List>(),
      ); // could be Uint64List or List<int> depending on platform
      expect(arr.toObject(), equals([1, 2, 9223372036854775807]));

      expect(
        () => CborUint64BigEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborUint64LittleEndianArray', () {
      final arr = CborUint64LittleEndianArray.fromList([
        1,
        2,
        9223372036854775807,
      ]);
      expect(arr.tags, equals([CborTag.uint64ArrayLE]));
      expect(arr.toObject(), isA<List>());
      expect(arr.toObject(), equals([1, 2, 9223372036854775807]));

      expect(
        () => CborUint64LittleEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt8Array', () {
      final arr = CborInt8Array.fromList([1, -2, 127, -128]);
      expect(arr.tags, equals([CborTag.sint8Array]));
      expect(arr.toObject(), isA<Int8List>());
      expect(arr.toObject(), equals([1, -2, 127, -128]));
    });

    test('CborInt16BigEndianArray', () {
      final arr = CborInt16BigEndianArray.fromList([1, -2, 32767, -32768]);
      expect(arr.tags, equals([CborTag.sint16ArrayBE]));
      expect(arr.toObject(), isA<Int16List>());
      expect(arr.toObject(), equals([1, -2, 32767, -32768]));

      expect(
        () => CborInt16BigEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt16LittleEndianArray', () {
      final arr = CborInt16LittleEndianArray.fromList([1, -2, 32767, -32768]);
      expect(arr.tags, equals([CborTag.sint16ArrayLE]));
      expect(arr.toObject(), isA<Int16List>());
      expect(arr.toObject(), equals([1, -2, 32767, -32768]));

      expect(
        () => CborInt16LittleEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt32BigEndianArray', () {
      final arr = CborInt32BigEndianArray.fromList([
        1,
        -2,
        2147483647,
        -2147483648,
      ]);
      expect(arr.tags, equals([CborTag.sint32ArrayBE]));
      expect(arr.toObject(), isA<Int32List>());
      expect(arr.toObject(), equals([1, -2, 2147483647, -2147483648]));

      expect(
        () => CborInt32BigEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt32LittleEndianArray', () {
      final arr = CborInt32LittleEndianArray.fromList([
        1,
        -2,
        2147483647,
        -2147483648,
      ]);
      expect(arr.tags, equals([CborTag.sint32ArrayLE]));
      expect(arr.toObject(), isA<Int32List>());
      expect(arr.toObject(), equals([1, -2, 2147483647, -2147483648]));

      expect(
        () => CborInt32LittleEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt64BigEndianArray', () {
      final arr = CborInt64BigEndianArray.fromList([
        1,
        -2,
        9223372036854775807,
        -9223372036854775808,
      ]);
      expect(arr.tags, equals([CborTag.sint64ArrayBE]));
      expect(arr.toObject(), isA<List>()); // Int64List or List<int>
      expect(
        arr.toObject(),
        equals([1, -2, 9223372036854775807, -9223372036854775808]),
      );

      expect(
        () => CborInt64BigEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborInt64LittleEndianArray', () {
      final arr = CborInt64LittleEndianArray.fromList([
        1,
        -2,
        9223372036854775807,
        -9223372036854775808,
      ]);
      expect(arr.tags, equals([CborTag.sint64ArrayLE]));
      expect(arr.toObject(), isA<List>());
      expect(
        arr.toObject(),
        equals([1, -2, 9223372036854775807, -9223372036854775808]),
      );

      expect(
        () => CborInt64LittleEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat16BigEndianArray', () {
      // 1.5 in half precision is 0x3E00
      final arr = CborFloat16BigEndianArray([0x3e, 0x00]);
      expect(arr.toObject(), equals([1.5]));

      expect(
        () => CborFloat16BigEndianArray([0x3e]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat16LittleEndianArray', () {
      // 1.5 in half precision little endian is 0x003E
      final arr = CborFloat16LittleEndianArray([0x00, 0x3e]);
      expect(arr.toObject(), equals([1.5]));

      expect(
        () => CborFloat16LittleEndianArray([0x00]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat32BigEndianArray', () {
      final arr = CborFloat32BigEndianArray.fromList([1.5, -2.5]);
      expect(arr.tags, equals([CborTag.float32ArrayBE]));
      expect(arr.toObject(), isA<Float32List>());
      expect(arr.toObject(), equals([1.5, -2.5]));

      expect(
        () => CborFloat32BigEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat32LittleEndianArray', () {
      final arr = CborFloat32LittleEndianArray.fromList([1.5, -2.5]);
      expect(arr.tags, equals([CborTag.float32ArrayLE]));
      expect(arr.toObject(), isA<Float32List>());
      expect(arr.toObject(), equals([1.5, -2.5]));

      expect(
        () => CborFloat32LittleEndianArray([0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat64BigEndianArray', () {
      final arr = CborFloat64BigEndianArray.fromList([1.5, -2.5]);
      expect(arr.tags, equals([CborTag.float64ArrayBE]));
      expect(arr.toObject(), isA<Float64List>());
      expect(arr.toObject(), equals([1.5, -2.5]));

      expect(
        () => CborFloat64BigEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat64LittleEndianArray', () {
      final arr = CborFloat64LittleEndianArray.fromList([1.5, -2.5]);
      expect(arr.tags, equals([CborTag.float64ArrayLE]));
      expect(arr.toObject(), isA<Float64List>());
      expect(arr.toObject(), equals([1.5, -2.5]));

      expect(
        () => CborFloat64LittleEndianArray([0, 0, 0, 0, 0, 0, 0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat128BigEndianArray', () {
      expect(
        () => CborFloat128BigEndianArray(List.filled(16, 0)).toObject(),
        throwsA(isA<UnimplementedError>()),
      );

      expect(
        () => CborFloat128BigEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });

    test('CborFloat128LittleEndianArray', () {
      expect(
        () => CborFloat128LittleEndianArray(List.filled(16, 0)).toObject(),
        throwsA(isA<UnimplementedError>()),
      );

      expect(
        () => CborFloat128LittleEndianArray([0]).toObject(),
        throwsA(isA<CborMalformedException>()),
      );
    });
  });
}
