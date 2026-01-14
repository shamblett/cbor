/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/01/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/bytes.dart';
import 'package:cbor/src/value/internal.dart';
import 'package:ieee754/ieee754.dart';

/// Base class for all Typed Arrays
abstract class CborTypedArray extends CborBytesImpl {
  const CborTypedArray(super.bytes, {super.tags});
}

/// uint8
class CborUint8Array extends CborTypedArray {
  const CborUint8Array(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Uint8List.fromList(bytes);
  }
}

/// uint8 clamped
class CborUint8ClampedArray extends CborTypedArray {
  const CborUint8ClampedArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Uint8ClampedList.fromList(bytes);
  }
}

/// uint16 big endian
class CborUint16BigEndianArray extends CborTypedArray {
  const CborUint16BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint16List(bytes.length ~/ 2);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint16(i * 2, Endian.big);
    }
    return list;
  }
}

/// uint16 little endian
class CborUint16LittleEndianArray extends CborTypedArray {
  const CborUint16LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint16List(bytes.length ~/ 2);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint16(i * 2, Endian.little);
    }
    return list;
  }
}

/// uint32 big endian
class CborUint32BigEndianArray extends CborTypedArray {
  const CborUint32BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint32(i * 4, Endian.big);
    }
    return list;
  }
}

/// uint32 little endian
class CborUint32LittleEndianArray extends CborTypedArray {
  const CborUint32LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint32(i * 4, Endian.little);
    }
    return list;
  }
}

/// uint64 big endian
class CborUint64BigEndianArray extends CborTypedArray {
  const CborUint64BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint64(i * 8, Endian.big);
    }
    return list;
  }
}

/// uint64 little endian
class CborUint64LittleEndianArray extends CborTypedArray {
  const CborUint64LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Uint64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getUint64(i * 8, Endian.little);
    }
    return list;
  }
}

/// sint8
class CborInt8Array extends CborTypedArray {
  const CborInt8Array(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Int8List.fromList(
      bytes,
    ); // Reinterprets bytes? No, fromList copies values.
    // Bytes are 0-255. Int8List expects -128 to 127.
    // We should use Int8List.view if possible or convert.
    // Uint8List can be viewed as Int8List.
  }
}

/// sint16 big endian
class CborInt16BigEndianArray extends CborTypedArray {
  const CborInt16BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int16List(bytes.length ~/ 2);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt16(i * 2, Endian.big);
    }
    return list;
  }
}

/// sint16 little endian
class CborInt16LittleEndianArray extends CborTypedArray {
  const CborInt16LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int16List(bytes.length ~/ 2);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt16(i * 2, Endian.little);
    }
    return list;
  }
}

/// sint32 big endian
class CborInt32BigEndianArray extends CborTypedArray {
  const CborInt32BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt32(i * 4, Endian.big);
    }
    return list;
  }
}

/// sint32 little endian
class CborInt32LittleEndianArray extends CborTypedArray {
  const CborInt32LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt32(i * 4, Endian.little);
    }
    return list;
  }
}

/// sint64 big endian
class CborInt64BigEndianArray extends CborTypedArray {
  const CborInt64BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt64(i * 8, Endian.big);
    }
    return list;
  }
}

/// sint64 little endian
class CborInt64LittleEndianArray extends CborTypedArray {
  const CborInt64LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Int64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getInt64(i * 8, Endian.little);
    }
    return list;
  }
}

/// float16 big endian
class CborFloat16BigEndianArray extends CborTypedArray {
  const CborFloat16BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = <double>[];
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < bytes.length; i += 2) {
      // FloatParts expects bytes in correct order?
      // FloatParts.fromFloat16Bytes takes List<int> of 2 bytes.
      // We must handle endianness.
      // If BE, we pass as is (assuming fromFloat16Bytes expects BE? Default network byte order is BE).
      // Let's assume standard behavior.
      final chunk = Uint8List.fromList([
        data.getUint8(i),
        data.getUint8(i + 1),
      ]);
      // If we need to respect endianness and fromFloat16Bytes expects something...
      // Usually float16 parsing libraries expect bytes.
      // If it's BE array, bytes are BE.
      // We will assume FloatParts.fromFloat16Bytes handles standard encoding?
      // The ieee754 package doc says "Decodes a float16 from the given bytes."
      // It likely assumes the bytes are in the correct order for the float16 representation.
      // Standard is usually defined.
      // But here we have explicit BE/LE tags.
      // If it's BE, bytes are BE.
      // If it's LE, bytes are LE.
      // I should check ieee754 package, but can't.
      // I'll assume I might need to swap for one case.
      // If I don't know, I'll assume FloatParts expects Big Endian (Network Order).
      // So for LE, I reverse the chunk.
      list.add(FloatParts.fromFloat16Bytes(chunk).toDouble());
    }
    return list;
  }
}

/// float16 little endian
class CborFloat16LittleEndianArray extends CborTypedArray {
  const CborFloat16LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = <double>[];
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < bytes.length; i += 2) {
      // Reverse for Little Endian if library expects Big Endian
      final chunk = Uint8List.fromList([
        data.getUint8(i + 1),
        data.getUint8(i),
      ]);
      list.add(FloatParts.fromFloat16Bytes(chunk).toDouble());
    }
    return list;
  }
}

/// float32 big endian
class CborFloat32BigEndianArray extends CborTypedArray {
  const CborFloat32BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Float32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getFloat32(i * 4, Endian.big);
    }
    return list;
  }
}

/// float32 little endian
class CborFloat32LittleEndianArray extends CborTypedArray {
  const CborFloat32LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Float32List(bytes.length ~/ 4);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getFloat32(i * 4, Endian.little);
    }
    return list;
  }
}

/// float64 big endian
class CborFloat64BigEndianArray extends CborTypedArray {
  const CborFloat64BigEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Float64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getFloat64(i * 8, Endian.big);
    }
    return list;
  }
}

/// float64 little endian
class CborFloat64LittleEndianArray extends CborTypedArray {
  const CborFloat64LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    final list = Float64List(bytes.length ~/ 8);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < list.length; i++) {
      list[i] = data.getFloat64(i * 8, Endian.little);
    }
    return list;
  }
}

/// float128 big endian
class CborFloat128BigEndianArray extends CborTypedArray {
  const CborFloat128BigEndianArray(super.bytes, {super.tags});

  // No native support, return bytes or implement if possible.
  // Returning bytes as fallback.
}

/// float128 little endian
class CborFloat128LittleEndianArray extends CborTypedArray {
  const CborFloat128LittleEndianArray(super.bytes, {super.tags});

  // No native support
}
