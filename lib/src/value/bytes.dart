/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cbor/cbor.dart';

/// A CBOR byte array.
class CborBytes implements CborValue {
  const CborBytes(this.bytes, [this.hints = const []]);

  final List<int> bytes;
  @override
  String toString() => bytes.toString();
  @override
  bool operator ==(Object other) =>
      other is CborBytes && bytes.equals(other.bytes);
  @override
  int get hashCode => bytes.hashCode;
  @override
  final Iterable<int> hints;
}

/// A CBOR big int.
class CborBigInt extends CborBytes implements CborInt {
  const CborBigInt._(List<int> bytes, this._isNegative, Iterable<int> hints)
      : super(bytes, hints);

  factory CborBigInt(
    BigInt value, [
    Iterable<int>? hints,
  ]) {
    if (value.isNegative) {
      hints ??= [CborHint.negativeBignum];
      value = ~value;
    } else {
      hints ??= [CborHint.positiveBignum];
    }

    final b = Uint8List((value.bitLength + 7) ~/ 8);
    final negative = value.isNegative;

    for (var i = b.length - 1; i >= 0; i--) {
      b[i] = value.toUnsigned(8).toInt();
      value >>= 8;
    }

    return CborBigInt._(b, negative, hints);
  }

  const CborBigInt.fromBytes(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.positiveBignum],
  ]) : this._(bytes, false, hints);

  const CborBigInt.fromNegativeBytes(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.negativeBignum],
  ]) : this._(bytes, true, hints);

  final bool _isNegative;

  @override
  bool operator ==(Object other) =>
      other is CborBigInt &&
      bytes.equals(other.bytes) &&
      _isNegative == other._isNegative;

  @override
  BigInt toBigInt() {
    var data = BigInt.zero;
    for (final b in bytes) {
      data <<= 8;
      data |= BigInt.from(b);
    }

    return _isNegative ? ~data : data;
  }

  @override
  int toInt() => toBigInt().toInt();
}
