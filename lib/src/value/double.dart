/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:ieee754/ieee754.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import 'internal.dart';

/// A CBOR float.
///
/// Encoded to the least precision which can represent the value losslessly.
class CborFloat with CborValueMixin implements CborValue {
  const CborFloat(this.value, [this.tags = const []]);

  final double value;

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) => other is CborFloat && value == other.value;
  @override
  int get hashCode => value.hashCode;
  @override
  final List<int> tags;

  /// <nodoc>
  @override
  @internal
  void encode(EncodeSink sink) {
    sink.addTags(tags);

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

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }
}

/// A CBOR date time encoded as seconds since epoch in a float.
class CborDateTimeFloat extends CborFloat implements CborDateTime {
  const CborDateTimeFloat.fromSecondsSinceEpoch(
    double amount, [
    List<int> tags = const [CborTag.epochDateTime],
  ]) : super(amount, tags);

  CborDateTimeFloat(
    DateTime value, [
    List<int> tags = const [CborTag.epochDateTime],
  ]) : super(value.millisecondsSinceEpoch / 1000, tags);

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
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
      (value * 1000).round(),
      isUtc: true,
    );
  }
}
