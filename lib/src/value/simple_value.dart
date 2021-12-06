import 'package:cbor/cbor.dart';

/// A CBOR simple value without any additional content.
class CborSimpleValue implements CborValue {
  const CborSimpleValue(this.simpleValue, [this.hints = const []]);

  final int simpleValue;
  @override
  String toString() => simpleValue.toString();
  @override
  bool operator ==(Object other) =>
      other is CborSimpleValue && other.simpleValue == simpleValue;
  @override
  int get hashCode => simpleValue.hashCode;
  @override
  final Iterable<int> hints;
}

/// A CBOR null value.
class CborNull extends CborSimpleValue {
  const CborNull([Iterable<int> hints = const []]) : super(22, hints);
}

/// A CBOR undefined value.
class CborUndefined extends CborSimpleValue {
  const CborUndefined([Iterable<int> hints = const []]) : super(23, hints);
}

/// A CBOR boolean value.
class CborBool extends CborSimpleValue {
  const CborBool(this.value, [Iterable<int> hints = const []])
      : super(!value ? 20 : 21, hints);

  final bool value;
}
