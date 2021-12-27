/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'internal.dart';

/// A CBOR integer or big number.
///
/// Because CBOR integers can be up to 64-bit, which JS cannot represent,
/// they are converted to [BigInt].
///
/// If the incoming value has less than 53 bits, it is [CborSmallInt].
abstract class CborInt with CborValueMixin implements CborValue {
  factory CborInt(BigInt value, {List<int>? tags}) {
    if (value.bitLength < 53) {
      return CborSmallInt(value.toInt(), tags: tags ?? const []);
    }

    final bitLength = value.isNegative ? (~value).bitLength : value.bitLength;

    if (bitLength <= 64) {
      return _LargeInt(value, tags ?? const []);
    } else {
      return CborBigInt(value, tags);
    }
  }

  /// Return the value as a [BigInt].
  BigInt toBigInt();

  /// Return the value as [int].
  ///
  /// If the number does not fit, clamps to the max (or min) integer.
  int toInt();
}

/// A CBOR integer which can be represented losslessly as [int].
class CborSmallInt with CborValueMixin implements CborInt {
  const CborSmallInt(this.value, {this.tags = const []});

  final int value;

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) =>
      other is CborSmallInt && value == other.toInt();
  @override
  int get hashCode => value.hashCode;
  @override
  BigInt toBigInt() => BigInt.from(value);
  @override
  int toInt() => value;
  @override
  final List<int> tags;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  /// <nodoc>
  @override
  @internal
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    if (!value.isNegative) {
      sink.addHeaderInfo(0, Info.int(value));
    } else {
      sink.addHeaderInfo(1, Info.int(~value));
    }
  }
}

class _LargeInt with CborValueMixin implements CborInt {
  _LargeInt(this.value, this.tags);

  final BigInt value;

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) =>
      other is CborInt && toBigInt() == other.toBigInt();
  @override
  int get hashCode => value.hashCode;
  @override
  BigInt toBigInt() => value;
  @override
  int toInt() => value.toInt();
  @override
  final List<int> tags;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  /// <nodoc>
  @internal
  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    if (!value.isNegative) {
      sink.addHeaderInfo(0, Info.bigInt(value));
    } else {
      sink.addHeaderInfo(1, Info.bigInt(~value));
    }
  }
}

/// A CBOR datetieme encoded as seconds since epoch.
class CborDateTimeInt extends CborSmallInt implements CborDateTime {
  CborDateTimeInt(
    DateTime value, {
    List<int> tags = const [CborTag.epochDateTime],
  }) : super(
          (value.millisecondsSinceEpoch / 1000).round(),
          tags: tags,
        );

  const CborDateTimeInt.fromSecondsSinceEpoch(
    int value, {
    List<int> tags = const [CborTag.epochDateTime],
  }) : super(value, tags: tags);

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.parseDateTime) {
      return toDateTime();
    } else {
      return value;
    }
  }

  @override
  DateTime toDateTime() =>
      DateTime.fromMillisecondsSinceEpoch(1000 * value, isUtc: true);
}
