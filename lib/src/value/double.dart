/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

/// A CBOR float.
///
/// Encoded to the least precision which can represent the value losslessly.
class CborFloat implements CborValue {
  const CborFloat(this.value, [this.hints = const []]);

  final double value;

  @override
  String toString() => value.toString();
  @override
  bool operator ==(Object other) => other is CborFloat && value == other.value;
  @override
  int get hashCode => value.hashCode;
  @override
  final Iterable<int> hints;
}

/// A CBOR date time encoded as seconds since epoch in a float.
class CborDateTimeFloat extends CborFloat implements CborDateTime {
  const CborDateTimeFloat.fromSecondsSinceEpoch(
    double amount, [
    Iterable<int> hints = const [CborHint.epochDateTime],
  ]) : super(amount, hints);

  CborDateTimeFloat(
    DateTime value, [
    Iterable<int> hints = const [CborHint.epochDateTime],
  ]) : super(value.millisecondsSinceEpoch / 1000, hints);

  @override
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(
      (value * 1000).round(),
      isUtc: true,
    );
  }
}
