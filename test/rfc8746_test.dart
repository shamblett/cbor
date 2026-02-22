/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/01/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('RFC 8746 Typed Arrays -> ', () {
    test('Tag 64 Uint8Array', () {
      final encoded = [
        0xd8,
        0x40,
        0x42,
        0x01,
        0x02,
      ]; // Tag 64, Bytes(2), 01, 02
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint8Array>());
      final array = decoded as CborUint8Array;
      expect(array.tags, [64]);
      expect(array.bytes, [1, 2]);
      expect(array.toObject(), isA<Uint8List>());
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 65 Uint16ArrayBE', () {
      final encoded = [
        0xd8,
        0x41,
        0x44,
        0x00,
        0x01,
        0x00,
        0x02,
      ]; // Tag 65, Bytes(4), 0001, 0002
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint16BigEndianArray>());
      final array = decoded as CborUint16BigEndianArray;
      expect(array.toObject(), isA<Uint16List>());
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 69 Uint16ArrayLE', () {
      final encoded = [
        0xd8,
        0x45,
        0x44,
        0x01,
        0x00,
        0x02,
        0x00,
      ]; // Tag 69, Bytes(4), 0100, 0200
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint16LittleEndianArray>());
      final array = decoded as CborUint16LittleEndianArray;
      expect(array.toObject(), isA<Uint16List>());
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 66 Uint32ArrayBE', () {
      final encoded = [
        0xd8,
        0x42,
        0x48,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x02,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint32BigEndianArray>());
      final array = decoded as CborUint32BigEndianArray;
      expect(array.toObject(), isA<Uint32List>());
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 70 Uint32ArrayLE', () {
      final encoded = [
        0xd8,
        0x46,
        0x48,
        0x01,
        0x00,
        0x00,
        0x00,
        0x02,
        0x00,
        0x00,
        0x00,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint32LittleEndianArray>());
      final array = decoded as CborUint32LittleEndianArray;
      expect(array.toObject(), isA<Uint32List>());
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 67 Uint64ArrayBE', () {
      final encoded = [
        0xd8,
        0x43,
        0x50, // Tag 67, Bytes(16)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint64BigEndianArray>());
      final array = decoded as CborUint64BigEndianArray;
      // On web, returns List<int> instead of Uint64List
      expect(array.toObject(), [1, 2]);
    });

    test('Tag 72 Int8Array', () {
      // -1 (0xFF), 1 (0x01)
      final encoded = [0xd8, 0x48, 0x42, 0xFF, 0x01];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborInt8Array>());
      final array = decoded as CborInt8Array;
      expect(array.toObject(), isA<Int8List>());
      expect(array.toObject(), [-1, 1]);
    });

    test('Tag 73 Int16ArrayBE', () {
      // -1 (0xFFFF), 1 (0x0001)
      final encoded = [0xd8, 0x49, 0x44, 0xFF, 0xFF, 0x00, 0x01];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborInt16BigEndianArray>());
      final array = decoded as CborInt16BigEndianArray;
      expect(array.toObject(), isA<Int16List>());
      expect(array.toObject(), [-1, 1]);
    });

    test('Tag 74 Int32ArrayBE', () {
      // -1 (0xFFFFFFFF), 1 (0x00000001)
      final encoded = [
        0xd8,
        0x4a,
        0x48,
        0xFF,
        0xFF,
        0xFF,
        0xFF,
        0x00,
        0x00,
        0x00,
        0x01,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborInt32BigEndianArray>());
      final array = decoded as CborInt32BigEndianArray;
      expect(array.toObject(), isA<Int32List>());
      expect(array.toObject(), [-1, 1]);
    });

    test('Tag 77 Int16ArrayLE', () {
      final encoded = [0xd8, 0x4d, 0x44, 0xFF, 0xFF, 0x01, 0x00];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborInt16LittleEndianArray>());
      final array = decoded as CborInt16LittleEndianArray;
      expect(array.toObject(), isA<Int16List>());
      expect(array.toObject(), [-1, 1]);
    });

    test('Tag 81 Float32ArrayBE', () {
      // 1.0 (0x3f800000)
      final encoded = [0xd8, 0x51, 0x44, 0x3f, 0x80, 0x00, 0x00];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat32BigEndianArray>());
      final array = decoded as CborFloat32BigEndianArray;
      expect(array.toObject(), isA<Float32List>());
      expect(array.toObject(), [1.0]);
    });

    test('Tag 85 Float32ArrayLE', () {
      // 1.0 (0x0000803f)
      final encoded = [0xd8, 0x55, 0x44, 0x00, 0x00, 0x80, 0x3f];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat32LittleEndianArray>());
      final array = decoded as CborFloat32LittleEndianArray;
      expect(array.toObject(), isA<Float32List>());
      expect(array.toObject(), [1.0]);
    });

    test('Tag 82 Float64ArrayBE', () {
      // 1.0 (0x3ff0000000000000)
      final encoded = [
        0xd8,
        0x52,
        0x48,
        0x3f,
        0xf0,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat64BigEndianArray>());
      final array = decoded as CborFloat64BigEndianArray;
      expect(array.toObject(), isA<Float64List>());
      expect(array.toObject(), [1.0]);
    });

    test('Tag 86 Float64ArrayLE', () {
      // 1.0 (0x000000000000f03f)
      final encoded = [
        0xd8,
        0x56,
        0x48,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xf0,
        0x3f,
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat64LittleEndianArray>());
      final array = decoded as CborFloat64LittleEndianArray;
      expect(array.toObject(), isA<Float64List>());
      expect(array.toObject(), [1.0]);
    });

    // Float16 tests
    test('Tag 80 Float16ArrayBE', () {
      // 1.0 in Float16 is 0x3c00
      final encoded = [0xd8, 0x50, 0x42, 0x3c, 0x00];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat16BigEndianArray>());
      final array = decoded as CborFloat16BigEndianArray;
      expect(array.toObject(), isA<List<double>>());
      expect(array.toObject(), [1.0]);
    });

    test('Tag 84 Float16ArrayLE', () {
      // 1.0 in Float16 is 0x3c00 -> LE 0x003c
      final encoded = [0xd8, 0x54, 0x42, 0x00, 0x3c];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat16LittleEndianArray>());
      final array = decoded as CborFloat16LittleEndianArray;
      expect(array.toObject(), isA<List<double>>());
      expect(array.toObject(), [1.0]);
    });

    // Float128 tests (Unimplemented)
    test('Tag 83 Float128ArrayBE', () {
      final encoded = [0xd8, 0x53, 0x50, for (var i = 0; i < 16; i++) 0];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat128BigEndianArray>());
      final array = decoded as CborFloat128BigEndianArray;
      expect(() => array.toObject(), throwsUnimplementedError);
    });

    // Misaligned length tests
    test('Uint16ArrayBE Misaligned', () {
      final encoded = [0xd8, 0x41, 0x43, 0x00, 0x01, 0x00]; // 3 bytes
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint16BigEndianArray>());
      final array = decoded as CborUint16BigEndianArray;
      expect(() => array.toObject(), throwsA(isA<CborMalformedException>()));
    });

    test('Float128ArrayBE Misaligned', () {
      final encoded = [
        0xd8,
        0x53,
        0x4F,
        for (var i = 0; i < 15; i++) 0,
      ]; // 15 bytes
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborFloat128BigEndianArray>());
      final array = decoded as CborFloat128BigEndianArray;
      expect(() => array.toObject(), throwsA(isA<CborMalformedException>()));
    });

    // Factory tests
    test('Factory Uint16ArrayBE.fromList', () {
      final array = CborUint16BigEndianArray.fromList([1, 2]);
      expect(array.bytes, [0x00, 0x01, 0x00, 0x02]);
      expect(array.tags, [65]);
    });

    test('Factory Uint16ArrayLE.fromList', () {
      final array = CborUint16LittleEndianArray.fromList([1, 2]);
      expect(array.bytes, [0x01, 0x00, 0x02, 0x00]);
      expect(array.tags, [69]);
    });

    test('Factory Float32ArrayBE.fromList', () {
      final array = CborFloat32BigEndianArray.fromList([1.0]);
      // 1.0 (0x3f800000)
      expect(array.bytes, [0x3f, 0x80, 0x00, 0x00]);
    });

    test('Factory Float32ArrayLE.fromList', () {
      final array = CborFloat32LittleEndianArray.fromList([1.0]);
      // 1.0 (0x0000803f)
      expect(array.bytes, [0x00, 0x00, 0x80, 0x3f]);
    });

    // Multi-dimensional Array tests
    test('Tag 40 Multi-dimensional Array with Uint8Array', () {
      // 2x2 array of [1, 2, 3, 4]
      // Tag 40 (d8 28)
      // Array(2) (82)
      //   Dimensions Array(2) (82)
      //     2 (02)
      //     2 (02)
      //   Data: Tag 64 (d8 40)
      //     Bytes(4) (44)
      //       01 02 03 04
      final encoded = [
        0xd8, 0x28, // Tag 40
        0x82, // Array(2)
        0x82, 0x02, 0x02, // Dimensions [2, 2]
        0xd8, 0x40, // Tag 64 (Uint8Array)
        0x44, 0x01, 0x02, 0x03, 0x04, // Bytes
      ];
      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborMultiDimensionalArray>());
      final md = decoded as CborMultiDimensionalArray;
      expect(md.dimensions, [2, 2]);
      expect(md.data, isA<CborUint8Array>());
      final data = md.data as CborUint8Array;
      expect(data.toObject(), [1, 2, 3, 4]);
    });

    test('Tag 40 Multi-dimensional Array Encoding', () {
      final array = CborMultiDimensionalArray.fromTypedArray([
        2,
        2,
      ], CborUint8Array.fromList([1, 2, 3, 4]));
      final encoded = cbor.encode(array);
      // Check bytes
      final expected = [
        0xd8,
        0x28, // Tag 40
        0x82, // Array(2)
        0x82,
        0x02,
        0x02, // Dimensions [2, 2]
        0xd8,
        0x40, // Tag 64 (Uint8Array)
        0x44,
        0x01,
        0x02,
        0x03,
        0x04, // Bytes
      ];
      expect(encoded, expected);
    });
  });

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
