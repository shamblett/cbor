import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'internal.dart';

/// A CBOR simple value without any
/// additional content.
class CborSimpleValue with CborValueMixin implements CborValue {
  const CborSimpleValue(this.simpleValue, [this.tags = const []]);

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

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return simpleValue;
  }

  /// <nodoc>
  @internal
  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(7, Info.int(simpleValue));
  }
}

/// A CBOR null value.
class CborNull extends CborSimpleValue {
  const CborNull([List<int> tags = const []]) : super(22, tags);

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return null;
  }
}

/// A CBOR undefined value.
class CborUndefined extends CborSimpleValue {
  const CborUndefined([List<int> tags = const []]) : super(23, tags);

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return null;
  }
}

/// A CBOR boolean value.
class CborBool extends CborSimpleValue {
  const CborBool(this.value, [List<int> tags = const []])
      : super(!value ? 20 : 21, tags);

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return value;
  }

  final bool value;
}
