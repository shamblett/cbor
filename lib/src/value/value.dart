/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

export 'bytes.dart';
export 'double.dart';
export 'int.dart';
export 'list.dart';
export 'simple_value.dart';
export 'string.dart';

/// Hint for the content of something.
@sealed
class CborHint {
  CborHint._();

  static const int dateTimeString = 0;
  static const int epochDateTime = 1;
  static const int positiveBignum = 2;
  static const int negativeBignum = 3;
  static const int decimalFraction = 4;
  static const int bigFloat = 5;
  static const int encodedCborData = 24;
  static const int expectedConversionToBase64 = 22;
  static const int expectedConversionToBase64url = 21;
  static const int expectedConversionToBase16 = 23;
  static const int uri = 32;
  static const int base64Url = 33;
  static const int base64 = 34;
  static const int regex = 35;
  static const int mime = 36;
  static const int selfDescribeCbor = 55799;
}

/// A CBOR value.
@sealed
abstract class CborValue {
  /// Additional hints provided to the value.
  Iterable<int> get hints;
}

/// A CBOR datetime.
abstract class CborDateTime implements CborValue {
  /// Converts the value to [DateTime], throwing [FormatException] if fails.
  DateTime toDateTime();
}

/// A CBOR map.
class CborMap extends DelegatingMap<CborValue, CborValue> implements CborValue {
  const CborMap(
      [Map<CborValue, CborValue> items = const {}, this.hints = const []])
      : super(items);
  CborMap.fromEntries(Iterable<MapEntry<CborValue, CborValue>> entries,
      [this.hints = const []])
      : super(Map.fromEntries(entries));

  @override
  final Iterable<int> hints;
}
