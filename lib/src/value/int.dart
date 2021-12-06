/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

/// A CBOR integer or big number.
///
/// Because CBOR integers can be up to 64-bit, which JS cannot represent,
/// they are converted to [BigInt].
///
/// If the incoming value has less than 53 bits, it is [CborSmallInt].
abstract class CborInt implements CborValue {
  factory CborInt(BigInt value, [Iterable<int> hints = const []]) {
    if (value.bitLength < 53) {
      return CborSmallInt(value.toInt(), hints);
    } else if (value.bitLength <= 64) {
      return _LargeInt(value, hints);
    } else {
      return CborBigInt(value, hints);
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
class CborSmallInt implements CborInt {
  const CborSmallInt(this.value, [this.hints = const []]);

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
  final Iterable<int> hints;
}

class _LargeInt implements CborInt {
  _LargeInt(this.value, this.hints);

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
  final Iterable<int> hints;
}

/// A CBOR datetieme encoded as seconds since epoch.
class CborDateTimeInt extends CborSmallInt implements CborDateTime {
  CborDateTimeInt(
    DateTime value, [
    Iterable<int> hints = const [CborHint.epochDateTime],
  ]) : super(
          (value.millisecondsSinceEpoch / 1000).round(),
          hints,
        );

  const CborDateTimeInt.fromSecondsSinceEpoch(
    int value, [
    Iterable<int> hints = const [CborHint.epochDateTime],
  ]) : super(value, hints);

  @override
  DateTime toDateTime() =>
      DateTime.fromMillisecondsSinceEpoch(1000 * value, isUtc: true);
}
