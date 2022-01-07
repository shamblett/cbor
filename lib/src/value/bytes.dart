/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';
import 'package:hex/hex.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';
import 'internal.dart';

/// A CBOR byte array.
abstract class CborBytes extends CborValue {
  factory CborBytes(List<int> bytes, {List<int> tags}) = _CborBytesImpl;

  List<int> get bytes;
}

class _CborBytesImpl with CborValueMixin implements CborBytes {
  const _CborBytesImpl(this.bytes, {this.tags = const []});

  @override
  final List<int> bytes;
  @override
  final List<int> tags;

  @override
  String toString() => bytes.toString();
  @override
  bool operator ==(Object other) =>
      other is CborBytes &&
      tags.equals(other.tags) &&
      bytes.equals(other.bytes);
  @override
  int get hashCode => Object.hashAll([bytes, tags].flattened);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return bytes;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    switch (expectedConversion ?? o.encoding) {
      case JsonBytesEncoding.base16:
        return const HexEncoder(upperCase: true).convert(bytes);
      case JsonBytesEncoding.base64:
        return base64.encode(bytes);
      case JsonBytesEncoding.base64Url:
        return base64Url.encode(bytes).replaceAll('=', '');
    }
  }

  @override
  void encode(EncodeSink sink) {
    CborEncodeDefiniteLengthBytes(this).encode(sink);
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length byte string.
///
/// This is never generated by decoder.
abstract class CborEncodeIndefiniteLengthBytes extends CborValue {
  factory CborEncodeIndefiniteLengthBytes(List<List<int>> items,
      {List<int> tags}) = _CborEncodeIndefiniteLengthBytesImpl;
}

class _CborEncodeIndefiniteLengthBytesImpl
    with CborValueMixin
    implements CborEncodeIndefiniteLengthBytes {
  const _CborEncodeIndefiniteLengthBytesImpl(this.items,
      {this.tags = const []});

  final List<List<int>> items;
  @override
  final List<int> tags;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return CborBytes(items.flattened.toList(), tags: tags)
        .toObjectInternal(cyclicCheck, o);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return CborBytes(items.flattened.toList(), tags: tags)
        .toJsonInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(2, Arg.indefiniteLength);

    for (final value in items) {
      CborEncodeDefiniteLengthBytes(CborBytes(value)).encode(sink);
    }

    (const Break()).encode(sink);
  }
}

/// Use this to force the [CborEncoder] to encode an definite length byte string.
///
/// This is never generated by decoder.
abstract class CborEncodeDefiniteLengthBytes extends CborValue {
  factory CborEncodeDefiniteLengthBytes(CborBytes input) =
      _CborEncodeDefiniteLengthBytesImpl;
}

class _CborEncodeDefiniteLengthBytesImpl
    with CborValueMixin
    implements CborEncodeDefiniteLengthBytes {
  const _CborEncodeDefiniteLengthBytesImpl(this.inner);

  final CborBytes inner;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return inner.toObjectInternal(cyclicCheck, o);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return inner.toJsonInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(2, Arg.int(inner.bytes.length));

    sink.add(inner.bytes);
  }

  @override
  List<int> get tags => inner.tags;
}

/// A CBOR big int.
abstract class CborBigInt extends CborBytes implements CborInt {
  factory CborBigInt(
    BigInt value, [
    List<int>? tags,
  ]) {
    final negative = value.isNegative;
    if (value.isNegative) {
      tags ??= [CborTag.negativeBignum];
      value = ~value;
    } else {
      tags ??= [CborTag.positiveBignum];
    }

    final b = Uint8List((value.bitLength + 7) ~/ 8);

    for (var i = b.length - 1; i >= 0; i--) {
      b[i] = value.toUnsigned(8).toInt();
      value >>= 8;
    }

    if (negative) {
      return CborBigInt.fromNegativeBytes(b, tags: tags);
    } else {
      return CborBigInt.fromBytes(b, tags: tags);
    }
  }

  factory CborBigInt.fromBytes(List<int> bytes, {List<int> tags}) =
      _CborBigIntImpl.fromBytes;

  factory CborBigInt.fromNegativeBytes(List<int> bytes, {List<int> tags}) =
      _CborBigIntImpl.fromNegativeBytes;

  bool get isNegative;
}

class _CborBigIntImpl extends _CborBytesImpl implements CborBigInt {
  const _CborBigIntImpl.fromBytes(
    List<int> bytes, {
    List<int> tags = const [CborTag.positiveBignum],
  })  : isNegative = false,
        super(bytes, tags: tags);

  const _CborBigIntImpl.fromNegativeBytes(
    List<int> bytes, {
    List<int> tags = const [CborTag.negativeBignum],
  })  : isNegative = true,
        super(bytes, tags: tags);

  @override
  final bool isNegative;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return toBigInt();
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    final output = StringBuffer();

    if (isNegative) {
      output.write('~');
    }

    output.write(super.toJsonInternal(
        cyclicCheck, o.copyWith(encoding: JsonBytesEncoding.base64Url)));
    return output.toString();
  }

  @override
  BigInt toBigInt() {
    var data = BigInt.zero;
    for (final b in bytes) {
      data <<= 8;
      data |= BigInt.from(b);
    }

    return isNegative ? ~data : data;
  }

  @override
  int toInt() => toBigInt().toInt();
}
