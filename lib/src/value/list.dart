/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'internal.dart';

/// A CBOR array.
abstract class CborList extends CborValue implements List<CborValue> {
  /// Create a new [CborList] from a view of the given list.
  const factory CborList(List<CborValue> items, {List<int> tags}) =
      _CborListImpl;

  /// Create a new [CborList] from values.
  ///
  /// The resulting list is growable.
  factory CborList.of(Iterable<CborValue> elements, {List<int> tags}) =
      _CborListImpl.of;

  /// Create a new [CborList] from generator.
  ///
  /// The resulting list is growable.
  factory CborList.generate(int len, CborValue Function(int index) f,
      {List<int> tags}) = _CborListImpl.generate;
}

class _CborListImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborList {
  const _CborListImpl(List<CborValue> items, {this.tags = const []})
      : super(items);

  _CborListImpl.of(Iterable<CborValue> elements, {this.tags = const []})
      : super(List.of(elements));
  _CborListImpl.generate(
    int len,
    CborValue Function(int index) f, {
    this.tags = const [],
  }) : super(List.generate(len, f));

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (!cyclicCheck.add(this)) {
      throw CborCyclicError(this);
    }

    final res = map((i) => i.toObjectInternal(cyclicCheck, o)).toList();

    cyclicCheck.remove(this);

    return res;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    if (!cyclicCheck.add(this)) {
      throw CborCyclicError(this);
    }

    final res = map((i) => i.toJsonInternal(
        cyclicCheck,
        o.copyWith(
          encoding: expectedConversion,
        ))).toList();

    cyclicCheck.remove(this);

    return res;
  }

  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    if (length < 256) {
      CborEncodeDefiniteLengthList(this).encode(sink);
    } else {
      // Indefinite length
      CborEncodeIndefiniteLengthList(this).encode(sink);
    }
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length list.
///
/// This is never generated by decoder.
abstract class CborEncodeIndefiniteLengthList extends CborValue {
  const factory CborEncodeIndefiniteLengthList(CborList x) =
      _CborEncodeIndefiniteLengthListImpl;
}

class _CborEncodeIndefiniteLengthListImpl
    with CborValueMixin
    implements CborEncodeIndefiniteLengthList {
  const _CborEncodeIndefiniteLengthListImpl(this.inner);

  final CborList inner;

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return inner.toJsonInternal(cyclicCheck, o);
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return inner.toObjectInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(4, Info.indefiniteLength);

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }

    sink.removeFromCycleCheck(inner);

    (const Break()).encode(sink);
  }

  @override
  List<int> get tags => inner.tags;
}

/// Use this to force the [CborEncoder] to encode an definite length list.
///
/// This is never generated by decoder.
abstract class CborEncodeDefiniteLengthList extends CborValue {
  const factory CborEncodeDefiniteLengthList(CborList list) =
      _CborEncodeDefiniteLengthListImpl;
}

class _CborEncodeDefiniteLengthListImpl
    with CborValueMixin
    implements CborEncodeDefiniteLengthList {
  const _CborEncodeDefiniteLengthListImpl(this.inner);

  final CborList inner;

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

    sink.addHeaderInfo(4, Info.int(inner.length));

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }
    sink.removeFromCycleCheck(inner);
  }

  @override
  List<int> get tags => inner.tags;
}

/// A CBOR fraction (m * (10 ** e)).
abstract class CborDecimalFraction extends CborList {
  factory CborDecimalFraction({
    required CborInt exponent,
    required CborInt mantissa,
    List<int> tags,
  }) = _CborDecimalFractionImpl;

  CborInt get exponent;

  CborInt get mantissa;
}

class _CborDecimalFractionImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborDecimalFraction {
  _CborDecimalFractionImpl({
    required this.exponent,
    required this.mantissa,
    this.tags = const [CborTag.decimalFraction],
  }) : super(List.of([exponent, mantissa], growable: false));

  @override
  final CborInt exponent;
  @override
  final CborInt mantissa;

  @override
  final List<int> tags;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return [exponent.toInt(), mantissa.toBigInt()];
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return [
      exponent.toJsonInternal(cyclicCheck, o),
      mantissa.toJsonInternal(cyclicCheck, o),
    ];
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(4, Info.int(2));
    exponent.encode(sink);
    mantissa.encode(sink);
  }
}

/// A CBOR fraction (m * (2 ** e)).
abstract class CborBigFloat extends CborList {
  factory CborBigFloat({
    required CborInt exponent,
    required CborInt mantissa,
    List<int> tags,
  }) = _CborBigFloatImpl;

  CborInt get exponent;
  CborInt get mantissa;
}

class _CborBigFloatImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborBigFloat {
  _CborBigFloatImpl({
    required this.exponent,
    required this.mantissa,
    this.tags = const [CborTag.bigFloat],
  }) : super(List.of([exponent, mantissa], growable: false));

  @override
  final CborInt exponent;
  @override
  final CborInt mantissa;

  @override
  final List<int> tags;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return [exponent.toInt(), mantissa.toBigInt()];
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(4, Info.int(2));
    exponent.encode(sink);
    mantissa.encode(sink);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return [
      exponent.toJsonInternal(cyclicCheck, o),
      mantissa.toJsonInternal(cyclicCheck, o),
    ];
  }
}
