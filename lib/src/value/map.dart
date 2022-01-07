/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';
import 'internal.dart';

/// A CBOR map.
abstract class CborMap implements Map<CborValue, CborValue>, CborValue {
  /// Create a new [CborMap] from a view of the given map.
  factory CborMap(Map<CborValue, CborValue> items, {List<int> tags}) =
      _CborMapImpl;

  /// Create a new [CborMap] as a copy of the given map.
  factory CborMap.of(Map<CborValue, CborValue> items, {List<int> tags}) =
      _CborMapImpl.of;

  /// Create a new [CborMap] from entries.
  factory CborMap.fromEntries(Iterable<MapEntry<CborValue, CborValue>> entries,
      {List<int> tags}) = _CborMapImpl.fromEntries;

  /// Create a new [CborMap] from key and value.
  factory CborMap.fromIterables(
      Iterable<CborValue> key, Iterable<CborValue> values,
      {List<int> tags}) = _CborMapImpl.fromIterables;
}

class _CborMapImpl extends DelegatingMap<CborValue, CborValue>
    with CborValueMixin
    implements CborMap {
  const _CborMapImpl(Map<CborValue, CborValue> items, {this.tags = const []})
      : super(items);
  _CborMapImpl.of(Map<CborValue, CborValue> items, {this.tags = const []})
      : super(Map.of(items));
  _CborMapImpl.fromEntries(Iterable<MapEntry<CborValue, CborValue>> entries,
      {this.tags = const []})
      : super(Map.fromEntries(entries));
  _CborMapImpl.fromIterables(
    Iterable<CborValue> keys,
    Iterable<CborValue> values, {
    this.tags = const [],
  }) : super(Map.fromIterables(keys, values));

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (!cyclicCheck.add(this)) {
      throw CborCyclicError(this);
    }

    final result = Map.fromEntries(entries.map((a) => MapEntry(
          a.key.toObjectInternal(cyclicCheck, o),
          a.value.toObjectInternal(cyclicCheck, o),
        )));

    cyclicCheck.remove(this);

    return result;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    if (!cyclicCheck.add(this)) {
      throw CborCyclicError(this);
    }

    final result = Map.fromEntries(entries.map((a) {
      var k = a.key.toJsonInternal(cyclicCheck, o);
      if (k is! String) {
        k = json.encode(k);
      }

      final v = a.value.toJsonInternal(cyclicCheck, o);

      return MapEntry(k, v);
    }));

    cyclicCheck.remove(this);

    return result;
  }

  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    if (length < 256) {
      CborEncodeDefiniteLengthMap(this).encode(sink);
    } else {
      CborEncodeIndefiniteLengthMap(this).encode(sink);
    }
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length dictionary.
///
/// This is never generated by decoder.
abstract class CborEncodeIndefiniteLengthMap extends CborValue {
  factory CborEncodeIndefiniteLengthMap(CborMap x) =
      _CborEncodeIndefiniteLengthMapImpl;
}

class _CborEncodeIndefiniteLengthMapImpl
    with CborValueMixin
    implements CborEncodeIndefiniteLengthMap {
  const _CborEncodeIndefiniteLengthMapImpl(this.inner);

  final CborMap inner;

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

    sink.addHeaderInfo(5, Arg.indefiniteLength);

    sink.addToCycleCheck(inner);
    for (final e in inner.entries) {
      e.key.encode(sink);
      e.value.encode(sink);
    }
    sink.removeFromCycleCheck(inner);

    (const Break()).encode(sink);
  }

  @override
  List<int> get tags => inner.tags;
}

/// Use this to force the [CborEncoder] to encode an definite length dictionary.
///
/// This is never generated by decoder.
abstract class CborEncodeDefiniteLengthMap extends CborValue {
  factory CborEncodeDefiniteLengthMap(CborMap v) =
      _CborEncodeDefiniteLengthMapImpl;
}

class _CborEncodeDefiniteLengthMapImpl
    with CborValueMixin
    implements CborEncodeDefiniteLengthMap {
  const _CborEncodeDefiniteLengthMapImpl(this.inner);

  final CborMap inner;

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

    sink.addHeaderInfo(5, Arg.int(inner.length));

    sink.addToCycleCheck(inner);
    for (final e in inner.entries) {
      e.key.encode(sink);
      e.value.encode(sink);
    }
    sink.removeFromCycleCheck(inner);
  }

  @override
  List<int> get tags => inner.tags;
}
