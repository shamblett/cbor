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

    test('Tag 77 Int16ArrayLE', () {
      // -1 (0xFFFF), 1 (0x0100 in LE? No, 0x0100 is 256. 1 is 0x01 0x00)
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

    // Float16 tests depending on ieee754
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

    // Roundtrip test (Encode -> Decode)
    test('Roundtrip Uint16ArrayBE', () {
      // Create manually as we don't have encoder for TypedData -> CborTypedArray yet,
      // but we can create CborUint16BigEndianArray and encode it.
      // Wait, CborUint16BigEndianArray extends CborBytesImpl, which encodes as bytes with tags.

      final bytes = Uint8List(4);
      final bdata = ByteData.view(bytes.buffer);
      bdata.setUint16(0, 1, Endian.big);
      bdata.setUint16(2, 2, Endian.big);

      final array = CborUint16BigEndianArray(bytes, tags: [65]);

      final encoded = cbor.encode(array);
      expect(encoded, [0xd8, 0x41, 0x44, 0x00, 0x01, 0x00, 0x02]);

      final decoded = cbor.decode(encoded);
      expect(decoded, isA<CborUint16BigEndianArray>());
      expect((decoded as CborUint16BigEndianArray).toObject(), [1, 2]);
    });
  });
}
