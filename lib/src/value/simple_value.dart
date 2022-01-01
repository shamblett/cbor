import 'package:cbor/cbor.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'internal.dart';

/// A CBOR simple value without any
/// additional content.
abstract class CborSimpleValue extends CborValue {
  const factory CborSimpleValue(int simpleValue, {List<int> tags}) =
      _CborSimpleValueImpl;

  int get simpleValue;
}

class _CborSimpleValueImpl with CborValueMixin implements CborSimpleValue {
  const _CborSimpleValueImpl(this.simpleValue, {this.tags = const []});

  @override
  final int simpleValue;

  @override
  String toString() => simpleValue.toString();
  @override
  bool operator ==(Object other) =>
      other is CborSimpleValue && other.simpleValue == simpleValue;
  @override
  int get hashCode => simpleValue.hashCode;
  @override
  final List<int> tags;

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return simpleValue;
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(7, Info.int(simpleValue));
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
  const _CborNullImpl({List<int> tags = const []}) : super(22, tags: tags);

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
  const _CborUndefinedImpl({List<int> tags = const []}) : super(23, tags: tags);

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
  const factory CborBool(bool value, {List<int> tags}) = _CborBoolImpl;

  bool get value;
}

class _CborBoolImpl extends _CborSimpleValueImpl implements CborBool {
  const _CborBoolImpl(this.value, {List<int> tags = const []})
      : super(!value ? 20 : 21, tags: tags);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return value;
  }

  @override
  final bool value;
}
