/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 14/01/2026
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/internal.dart';
import 'package:ieee754/ieee754.dart';

/// Base class for all Typed Arrays
sealed class CborTypedArray extends CborBytesImpl {
  const CborTypedArray(super.bytes, {super.tags});
}

/// uint8
class CborUint8Array extends CborTypedArray {
  const CborUint8Array(super.bytes, {super.tags});

  factory CborUint8Array.fromList(List<int> list, {List<int>? tags}) {
    return CborUint8Array(
      Uint8List.fromList(list),
      tags: tags ?? [CborTag.uint8Array],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Uint8List.fromList(bytes);
  }
}

/// uint8 clamped
class CborUint8ClampedArray extends CborTypedArray {
  const CborUint8ClampedArray(super.bytes, {super.tags});

  factory CborUint8ClampedArray.fromList(List<int> list, {List<int>? tags}) {
    return CborUint8ClampedArray(
      Uint8ClampedList.fromList(list),
      tags: tags ?? [CborTag.uint8ArrayClamped],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Uint8ClampedList.fromList(bytes);
  }
}

/// uint16 big endian
class CborUint16BigEndianArray extends CborTypedArray {
  const CborUint16BigEndianArray(super.bytes, {super.tags});

  factory CborUint16BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 2);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint16(i * 2, list[i], Endian.big);
    }
    return CborUint16BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint16ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Uint16ArrayBE byte length not multiple of 2',
      );
    }
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

  factory CborUint16LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 2);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint16(i * 2, list[i], Endian.little);
    }
    return CborUint16LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint16ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Uint16ArrayLE byte length not multiple of 2',
      );
    }
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

  factory CborUint32BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint32(i * 4, list[i], Endian.big);
    }
    return CborUint32BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint32ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Uint32ArrayBE byte length not multiple of 4',
      );
    }
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

  factory CborUint32LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint32(i * 4, list[i], Endian.little);
    }
    return CborUint32LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint32ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Uint32ArrayLE byte length not multiple of 4',
      );
    }
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

  factory CborUint64BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint64(i * 8, list[i], Endian.big);
    }
    return CborUint64BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint64ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Uint64ArrayBE byte length not multiple of 8',
      );
    }
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

  factory CborUint64LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setUint64(i * 8, list[i], Endian.little);
    }
    return CborUint64LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.uint64ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Uint64ArrayLE byte length not multiple of 8',
      );
    }
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

  factory CborInt8Array.fromList(List<int> list, {List<int>? tags}) {
    // Int8List.fromList takes a List<int>, but values must be in signed range or they wrap/truncate.
    // We then convert to Uint8List for storage as 'bytes'.
    final int8List = Int8List.fromList(list);
    return CborInt8Array(
      Uint8List.view(int8List.buffer),
      tags: tags ?? [CborTag.sint8Array],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return Int8List.fromList(bytes);
  }
}

/// sint16 big endian
class CborInt16BigEndianArray extends CborTypedArray {
  const CborInt16BigEndianArray(super.bytes, {super.tags});

  factory CborInt16BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 2);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt16(i * 2, list[i], Endian.big);
    }
    return CborInt16BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint16ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Int16ArrayBE byte length not multiple of 2',
      );
    }
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

  factory CborInt16LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 2);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt16(i * 2, list[i], Endian.little);
    }
    return CborInt16LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint16ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Int16ArrayLE byte length not multiple of 2',
      );
    }
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

  factory CborInt32BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt32(i * 4, list[i], Endian.big);
    }
    return CborInt32BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint32ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Int32ArrayBE byte length not multiple of 4',
      );
    }
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

  factory CborInt32LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt32(i * 4, list[i], Endian.little);
    }
    return CborInt32LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint32ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Int32ArrayLE byte length not multiple of 4',
      );
    }
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

  factory CborInt64BigEndianArray.fromList(List<int> list, {List<int>? tags}) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt64(i * 8, list[i], Endian.big);
    }
    return CborInt64BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint64ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Int64ArrayBE byte length not multiple of 8',
      );
    }
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

  factory CborInt64LittleEndianArray.fromList(
    List<int> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setInt64(i * 8, list[i], Endian.little);
    }
    return CborInt64LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.sint64ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Int64ArrayLE byte length not multiple of 8',
      );
    }
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
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Float16ArrayBE byte length not multiple of 2',
      );
    }
    final list = <double>[];
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < bytes.length; i += 2) {
      final chunk = Uint8List.fromList([
        data.getUint8(i),
        data.getUint8(i + 1),
      ]);
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
    if (bytes.length % 2 != 0) {
      throw CborMalformedException(
        'Float16ArrayLE byte length not multiple of 2',
      );
    }
    final list = <double>[];
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    for (var i = 0; i < bytes.length; i += 2) {
      // Reverse for Little Endian as library expects Big Endian
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

  factory CborFloat32BigEndianArray.fromList(
    List<double> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setFloat32(i * 4, list[i], Endian.big);
    }
    return CborFloat32BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.float32ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Float32ArrayBE byte length not multiple of 4',
      );
    }
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

  factory CborFloat32LittleEndianArray.fromList(
    List<double> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 4);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setFloat32(i * 4, list[i], Endian.little);
    }
    return CborFloat32LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.float32ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 4 != 0) {
      throw CborMalformedException(
        'Float32ArrayLE byte length not multiple of 4',
      );
    }
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

  factory CborFloat64BigEndianArray.fromList(
    List<double> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setFloat64(i * 8, list[i], Endian.big);
    }
    return CborFloat64BigEndianArray(
      bytes,
      tags: tags ?? [CborTag.float64ArrayBE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Float64ArrayBE byte length not multiple of 8',
      );
    }
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

  factory CborFloat64LittleEndianArray.fromList(
    List<double> list, {
    List<int>? tags,
  }) {
    final bytes = Uint8List(list.length * 8);
    final data = ByteData.view(bytes.buffer);
    for (var i = 0; i < list.length; i++) {
      data.setFloat64(i * 8, list[i], Endian.little);
    }
    return CborFloat64LittleEndianArray(
      bytes,
      tags: tags ?? [CborTag.float64ArrayLE],
    );
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 8 != 0) {
      throw CborMalformedException(
        'Float64ArrayLE byte length not multiple of 8',
      );
    }
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

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 16 != 0) {
      throw CborMalformedException(
        'Float128ArrayBE byte length not multiple of 16',
      );
    }
    // No native support, return bytes or implement if possible.
    throw UnimplementedError('Float128ArrayBE not implemented in Dart');
  }
}

/// float128 little endian
class CborFloat128LittleEndianArray extends CborTypedArray {
  const CborFloat128LittleEndianArray(super.bytes, {super.tags});

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (bytes.length % 16 != 0) {
      throw CborMalformedException(
        'Float128ArrayLE byte length not multiple of 16',
      );
    }
    // No native support
    throw UnimplementedError('Float128ArrayLE not implemented in Dart');
  }
}
