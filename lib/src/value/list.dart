/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';
import 'internal.dart';

/// A CBOR array.
abstract class CborList extends CborValue implements List<CborValue> {
  CborLengthType get type;

  /// Create a new [CborList] from a view of the given list.
  factory CborList(
    List<CborValue> items, {
    List<int> tags,
    CborLengthType type,
  }) = _CborListImpl;

  /// Create a new [CborList] from values.
  ///
  /// The resulting list is growable.
  factory CborList.of(
    Iterable<CborValue> elements, {
    List<int> tags,
    CborLengthType type,
  }) = _CborListImpl.of;

  /// Create a new [CborList] from generator.
  ///
  /// The resulting list is growable.
  factory CborList.generate(
    int len,
    CborValue Function(int index) f, {
    List<int> tags,
  }) = _CborListImpl.generate;
}

class _CborListImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborList {
  @override
  final List<int> tags;

  @override
  final CborLengthType type;

  const _CborListImpl(
    super.items, {
    this.tags = const [],
    this.type = CborLengthType.auto,
  });

  _CborListImpl.of(
    Iterable<CborValue> elements, {
    this.tags = const [],
    this.type = CborLengthType.auto,
  }) : super(List.of(elements));

  _CborListImpl.generate(
    int len,
    CborValue Function(int index) f, {
    this.tags = const [],
    this.type = CborLengthType.auto,
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

    final res =
        map(
          (i) => i.toJsonInternal(
            cyclicCheck,
            o.copyWith(encoding: expectedConversion),
          ),
        ).toList();

    cyclicCheck.remove(this);

    return res;
  }

  @override
  void encode(EncodeSink sink) {
    if (type == CborLengthType.definite ||
        (type == CborLengthType.auto &&
            length < kCborDefiniteLengthThreshold)) {
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
  factory CborEncodeIndefiniteLengthList(CborList x) =
      _CborEncodeIndefiniteLengthListImpl;
}

class _CborEncodeIndefiniteLengthListImpl
    with CborValueMixin
    implements CborEncodeIndefiniteLengthList {
  final CborList inner;

  @override
  List<int> get tags => inner.tags;

  const _CborEncodeIndefiniteLengthListImpl(this.inner);

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

    sink.addHeaderInfo(CborMajorType.array, Arg.indefiniteLength);

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }

    sink.removeFromCycleCheck(inner);

    (const Break()).encode(sink);
  }
}

/// Use this to force the [CborEncoder] to encode an definite length list.
///
/// This is never generated by decoder.
abstract class CborEncodeDefiniteLengthList extends CborValue {
  factory CborEncodeDefiniteLengthList(CborList list) =
      _CborEncodeDefiniteLengthListImpl;
}

class _CborEncodeDefiniteLengthListImpl
    with CborValueMixin
    implements CborEncodeDefiniteLengthList {
  final CborList inner;

  @override
  List<int> get tags => inner.tags;

  const _CborEncodeDefiniteLengthListImpl(this.inner);

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

    sink.addHeaderInfo(CborMajorType.array, Arg.int(inner.length));

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }
    sink.removeFromCycleCheck(inner);
  }
}

/// A CBOR fraction (m * (10 ** e)).
abstract class CborDecimalFraction extends CborList {
  CborInt get exponent;

  CborInt get mantissa;

  factory CborDecimalFraction({
    required CborInt exponent,
    required CborInt mantissa,
    List<int> tags,
    CborLengthType type,
  }) = _CborDecimalFractionImpl;
}

class _CborDecimalFractionImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborDecimalFraction {
  @override
  final CborInt exponent;
  @override
  final CborInt mantissa;

  @override
  final List<int> tags;

  @override
  final CborLengthType type;

  _CborDecimalFractionImpl({
    required this.exponent,
    required this.mantissa,
    this.tags = const [CborTag.decimalFraction],
    this.type = CborLengthType.auto,
  }) : super(List.of([exponent, mantissa], growable: false));

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
    sink.addHeaderInfo(CborMajorType.array, switch (type) {
      CborLengthType.definite || CborLengthType.auto => const Arg.int(2),
      CborLengthType.indefinite => Arg.indefiniteLength,
    });
    exponent.encode(sink);
    mantissa.encode(sink);

    if (type == CborLengthType.indefinite) {
      (const Break()).encode(sink);
    }
  }
}

/// A CBOR rational number (m / n).
/// https://peteroupc.github.io/CBOR/rational.html
abstract class CborRationalNumber extends CborList {
  CborInt get numerator;

  CborInt get denominator;

  factory CborRationalNumber({
    required CborInt numerator,
    required CborInt denominator,
    List<int> tags,
    CborLengthType type,
  }) = _CborRationalNumberImpl;
}

class _CborRationalNumberImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborRationalNumber {
  @override
  final CborInt numerator;
  @override
  final CborInt denominator;

  @override
  final List<int> tags;

  @override
  final CborLengthType type;

  _CborRationalNumberImpl({
    required this.numerator,
    required this.denominator,
    this.tags = const [CborTag.rationalNumber],
    this.type = CborLengthType.auto,
  }) : assert(denominator.toInt() != 0),
       super(List.of([numerator, denominator], growable: false));

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return [numerator.toBigInt(), denominator.toBigInt()];
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return [
      numerator.toJsonInternal(cyclicCheck, o),
      denominator.toJsonInternal(cyclicCheck, o),
    ];
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(CborMajorType.array, switch (type) {
      CborLengthType.definite || CborLengthType.auto => const Arg.int(2),
      CborLengthType.indefinite => Arg.indefiniteLength,
    });
    numerator.encode(sink);
    denominator.encode(sink);

    if (type == CborLengthType.indefinite) {
      (const Break()).encode(sink);
    }
  }
}

/// A CBOR fraction (m * (2 ** e)).
abstract class CborBigFloat extends CborList {
  CborInt get exponent;

  CborInt get mantissa;

  factory CborBigFloat({
    required CborInt exponent,
    required CborInt mantissa,
    List<int> tags,
    CborLengthType type,
  }) = _CborBigFloatImpl;
}

class _CborBigFloatImpl extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborBigFloat {
  @override
  final CborInt exponent;
  @override
  final CborInt mantissa;

  @override
  final List<int> tags;
  @override
  final CborLengthType type;

  _CborBigFloatImpl({
    required this.exponent,
    required this.mantissa,
    this.tags = const [CborTag.bigFloat],
    this.type = CborLengthType.auto,
  }) : super(List.of([exponent, mantissa], growable: false));

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return [exponent.toInt(), mantissa.toBigInt()];
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(CborMajorType.array, switch (type) {
      CborLengthType.definite || CborLengthType.auto => const Arg.int(2),
      CborLengthType.indefinite => Arg.indefiniteLength,
    });
    exponent.encode(sink);
    mantissa.encode(sink);

    if (type == CborLengthType.indefinite) {
      (const Break()).encode(sink);
    }
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return [
      exponent.toJsonInternal(cyclicCheck, o),
      mantissa.toJsonInternal(cyclicCheck, o),
    ];
  }
}
