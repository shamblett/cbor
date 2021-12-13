import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'value.dart';

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

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(7, Info.int(simpleValue));
  }
}

/// A CBOR null value.
class CborNull extends CborSimpleValue {
  const CborNull([List<int> tags = const []]) : super(22, tags);
}

/// A CBOR undefined value.
class CborUndefined extends CborSimpleValue {
  const CborUndefined([List<int> tags = const []]) : super(23, tags);
}

/// A CBOR boolean value.
class CborBool extends CborSimpleValue {
  const CborBool(this.value, [List<int> tags = const []])
      : super(!value ? 20 : 21, tags);

  final bool value;
}

/// This is for internal usage and should not be returned to the user
///
/// <nodoc>
@internal
class Break extends CborSimpleValue {
  const Break() : super(31);

  @override
  final List<int> tags = const [];

  @override
  void encode(EncodeSink sink) {
    sink.addHeaderInfo(7, Info.indefiniteLength);
  }
}
