/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

/// A CBOR array.
class CborList extends DelegatingList<CborValue> implements CborValue {
  const CborList([List<CborValue> items = const [], this.hints = const []])
      : super(items);

  @override
  final Iterable<int> hints;
}

/// A CBOR fraction (m * (10 ** e)).
class CborDecimalFraction extends DelegatingList<CborValue>
    implements CborList {
  CborDecimalFraction(
    this.exponent,
    this.mantissa, [
    this.hints = const [],
  ]) : super([exponent, mantissa]);

  final CborInt exponent;

  final CborInt mantissa;

  @override
  final Iterable<int> hints;
}

/// A CBOR fraction (m * (2 ** e)).
class CborBigFloat extends DelegatingList<CborValue> implements CborList {
  CborBigFloat(
    this.exponent,
    this.mantissa, [
    this.hints = const [],
  ]) : super([exponent, mantissa]);

  final CborInt exponent;

  final CborInt mantissa;

  @override
  final Iterable<int> hints;
}
