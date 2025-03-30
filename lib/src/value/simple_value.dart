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

/// A CBOR simple value without any
/// additional content.

abstract class CborSimpleValue extends CborValue {
  int get simpleValue;

  const factory CborSimpleValue(int simpleValue, {List<int> tags}) =
      _CborSimpleValueImpl;
}

class _CborSimpleValueImpl with CborValueMixin implements CborSimpleValue {
  @override
  final int simpleValue;

  @override
  final List<int> tags;

  @override
  int get hashCode => Object.hash(simpleValue, Object.hashAll(tags));

  const _CborSimpleValueImpl(this.simpleValue, {this.tags = const []});

  @override
  String toString() => simpleValue.toString();
  @override
  bool operator ==(Object other) =>
      other is CborSimpleValue &&
      tags.equals(other.tags) &&
      other.simpleValue == simpleValue;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return simpleValue;
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(CborMajorType.simpleFloat, Arg.int(simpleValue));
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return o.substituteValue;
  }
}

/// A CBOR null value.
abstract class CborNull extends CborSimpleValue {
  const factory CborNull({List<int> tags}) = _CborNullImpl;
}

class _CborNullImpl extends _CborSimpleValueImpl implements CborNull {
  const _CborNullImpl({List<int> tags = const []})
    : super(CborAdditionalInfo.simpleNull, tags: tags);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return null;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return null;
  }
}

/// A CBOR undefined value.
abstract class CborUndefined extends CborSimpleValue {
  const factory CborUndefined({List<int> tags}) = _CborUndefinedImpl;
}

class _CborUndefinedImpl extends _CborSimpleValueImpl implements CborUndefined {
  const _CborUndefinedImpl({List<int> tags = const []})
    : super(CborAdditionalInfo.simpleUndefined, tags: tags);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return null;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return o.substituteValue;
  }
}

/// A CBOR boolean value.
abstract class CborBool extends CborSimpleValue {
  bool get value;

  const factory CborBool(bool value, {List<int> tags}) = _CborBoolImpl;
}

class _CborBoolImpl extends _CborSimpleValueImpl implements CborBool {
  @override
  final bool value;

  const _CborBoolImpl(this.value, {List<int> tags = const []})
    : super(
        !value ? CborAdditionalInfo.simpleFalse : CborAdditionalInfo.simpleTrue,
        tags: tags,
      );

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return value;
  }
}
