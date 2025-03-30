/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

import '../encoder/sink.dart';
import 'package:collection/collection.dart';
import '../constants.dart';
import '../utils/arg.dart';
import 'internal.dart';

/// A CBOR integer or big number.
///
/// Because CBOR integers can be up to 64-bit, which JS cannot represent,
/// they are converted to [BigInt].
///
/// If the incoming value has less than 53 bits, it is [CborSmallInt].
abstract class CborInt extends CborValue {
  factory CborInt(BigInt value, {List<int>? tags}) {
    if (value.isValidInt) {
      return CborSmallInt(value.toInt(), tags: tags ?? const []);
    }

    final bitLength = value.isNegative ? (~value).bitLength : value.bitLength;

    return bitLength <= CborConstants.bitsPerDoubleWord
        ? _LargeInt(value, tags ?? const [])
        : CborBigInt(value, tags);
  }

  /// Return the value as a [BigInt].
  BigInt toBigInt();

  /// Return the value as [int].
  ///
  /// If the number does not fit, clamps to the max (or min) integer.
  int toInt();
}

/// A CBOR integer which can be represented losslessly as [int].
abstract class CborSmallInt extends CborInt {
  int get value;

  const factory CborSmallInt(int value, {List<int> tags}) = _CborSmallIntImpl;
}

class _CborSmallIntImpl with CborValueMixin implements CborSmallInt {
  @override
  final int value;

  @override
  final List<int> tags;

  @override
  int get hashCode => Object.hash(value, Object.hashAll(tags));

  const _CborSmallIntImpl(this.value, {this.tags = const []});

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) =>
      other is CborSmallInt &&
      tags.equals(other.tags) &&
      value == other.toInt();

  @override
  BigInt toBigInt() => BigInt.from(value);
  @override
  int toInt() => value;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return value.bitLength < CborConstants.jsonBitLength
        ? value
        : CborBigInt(BigInt.from(value)).toJsonInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    if (!value.isNegative) {
      sink.addHeaderInfo(0, Arg.int(value));
    } else {
      sink.addHeaderInfo(1, Arg.int((~BigInt.from(value)).toInt()));
    }
  }
}

class _LargeInt with CborValueMixin implements CborInt {
  final BigInt value;

  @override
  final List<int> tags;

  @override
  int get hashCode => Object.hash(value, Object.hashAll(tags));

  _LargeInt(this.value, this.tags);

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) =>
      other is CborInt &&
      tags.equals(other.tags) &&
      toBigInt() == other.toBigInt();

  @override
  BigInt toBigInt() => value;
  @override
  int toInt() => value.toInt();

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return CborBigInt(value).toJsonInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    if (!value.isNegative) {
      sink.addHeaderInfo(0, Arg.bigInt(value));
    } else {
      sink.addHeaderInfo(1, Arg.bigInt(~value));
    }
  }
}

/// A CBOR datetieme encoded as seconds since epoch.
abstract class CborDateTimeInt extends CborSmallInt implements CborDateTime {
  factory CborDateTimeInt(DateTime value, {List<int> tags}) =
      _CborDateTimeIntImpl;

  factory CborDateTimeInt.fromSecondsSinceEpoch(int value, {List<int> tags}) =
      _CborDateTimeIntImpl.fromSecondsSinceEpoch;
}

/// A CBOR datetieme encoded as seconds since epoch.
class _CborDateTimeIntImpl extends _CborSmallIntImpl
    implements CborDateTimeInt {
  _CborDateTimeIntImpl(
    DateTime value, {
    List<int> tags = const [CborTag.epochDateTime],
  }) : super(
         (value.millisecondsSinceEpoch / CborConstants.milliseconds).round(),
         tags: tags,
       );

  const _CborDateTimeIntImpl.fromSecondsSinceEpoch(
    super.value, {
    super.tags = const [CborTag.epochDateTime],
  });

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return o.parseDateTime ? toDateTime() : value;
  }

  @override
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(
    value * CborConstants.milliseconds,
    isUtc: true,
  );
}
