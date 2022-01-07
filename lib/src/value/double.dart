/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';
import 'package:ieee754/ieee754.dart';

import '../encoder/sink.dart';
import 'internal.dart';

/// A CBOR float.
///
/// Encoded to the least precision which can represent the value losslessly.
abstract class CborFloat extends CborValue {
  const factory CborFloat(double value, {List<int> tags}) = _CborFloatImpl;

  double get value;
}

class _CborFloatImpl with CborValueMixin implements CborFloat {
  const _CborFloatImpl(this.value, {this.tags = const []});

  @override
  final double value;
  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) =>
      other is CborFloat && tags.equals(other.tags) && value == other.value;
  @override
  int get hashCode => Object.hash(value, Object.hashAll(tags));
  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    if (value.isNaN) {
      // Any bit pattern can be returned from `toFloat16Bytes()` as long as
      // it is NaN, so it's a good idea to make sure this is consistent.
      //
      // This value seems to be ideal as it is the value used in canonical
      // format
      //
      // https://datatracker.ietf.org/doc/html/rfc7049#page-27
      sink.add([0xf9, 0x7e, 0x00]);

      return;
    }

    final parts = FloatParts.fromDouble(value);

    if (parts.isFloat16Lossless) {
      sink.addHeader(7, 25);

      sink.add(parts.toFloat16Bytes());
    } else if (parts.isFloat32Lossless) {
      sink.addHeader(7, 26);

      sink.add(parts.toFloat32Bytes());
    } else {
      sink.addHeader(7, 27);

      sink.add(parts.toFloat64Bytes());
    }
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    if (value.isFinite) {
      return value;
    } else {
      return o.substituteValue;
    }
  }
}

/// A CBOR date time encoded as seconds since epoch in a float.
abstract class CborDateTimeFloat extends CborFloat implements CborDateTime {
  const factory CborDateTimeFloat.fromSecondsSinceEpoch(double amount,
      {List<int> tags}) = _CborDateTimeFloatImpl.fromSecondsSinceEpoch;

  factory CborDateTimeFloat(DateTime value, {List<int> tags}) =
      _CborDateTimeFloatImpl;
}

class _CborDateTimeFloatImpl extends _CborFloatImpl
    implements CborDateTimeFloat {
  const _CborDateTimeFloatImpl.fromSecondsSinceEpoch(
    double amount, {
    List<int> tags = const [CborTag.epochDateTime],
  }) : super(amount, tags: tags);

  _CborDateTimeFloatImpl(
    DateTime value, {
    List<int> tags = const [CborTag.epochDateTime],
  }) : super(value.millisecondsSinceEpoch / 1000, tags: tags);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.parseDateTime) {
      return toDateTime();
    } else {
      return value;
    }
  }

  @override
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
      (value * 1000).round(),
      isUtc: true,
    );
  }
}
