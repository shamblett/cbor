/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

// dart format width=123

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../constants.dart';
import '../encoder/sink.dart';
import 'internal.dart';

export 'bytes.dart';
export 'double.dart';
export 'int.dart';
export 'list.dart';
export 'map.dart';
export 'simple_value.dart';
export 'string.dart';

/// Jump table for initial byte values can be found <a href="https://www.rfc-editor.org/rfc/rfc8949.html#jumptable">here</a>.
/// Maybe useful for code maintainers.

/// Major types
sealed class CborMajorType {
  static const int uint = 0; // unsigned integer N
  static const int nint = 1; // negative integer -1-N
  static const int byteString = 2; // byte string
  static const int textString = 3; // text string
  static const int array = 4; // array
  static const int map = 5; // map
  static const int tag = 6; // tag of number N
  static const int simpleFloat = 7; // simple/float

  CborMajorType._();
}

/// Additional Info
sealed class CborAdditionalInfo {
  static const simpleValueLow = 23; // Simple value (value 0..23)
  static const simpleValueHigh = 24; // Simple value (value 32..255 in following byte)
  static const halfPrecisionFloat = 25; // IEEE 754 Half-Precision Float (16 bits follow)
  static const singlePrecisionFloat = 26; // IEEE 754 Single-Precision Float (32 bits follow)
  static const doublePrecisionFloat = 27; // IEEE 754 Double-Precision Float (64 bits follow)
  static const breakStop = 31; // Break" stop code for indefinite-length items
  static const simpleFalse = 20;
  static const simpleTrue = 21;
  static const simpleNull = 22;
  static const simpleUndefined = 23;
}

/// Hint for the content of something.
sealed class CborTag {
  static const int dateTimeString = 0;
  static const int epochDateTime = 1;
  static const int positiveBignum = 2;
  static const int negativeBignum = 3;
  static const int decimalFraction = 4;
  static const int bigFloat = 5;
  static const int encodedCborData = 24;
  static const int expectedConversionToBase64 = 22;
  static const int expectedConversionToBase64Url = 21;
  static const int expectedConversionToBase16 = 23;
  static const int rationalNumber = 30;
  static const int uri = 32;
  static const int base64Url = 33;
  static const int base64 = 34;
  static const int regex = 35;
  static const int mime = 36;
  static const int selfDescribeCbor = 55799;

  CborTag._();
}

const kCborDefiniteLengthThreshold = 256;

enum CborLengthType { definite, indefinite, auto }

/// A CBOR value.
abstract class CborValue {
  /// Additional tags provided to the value.
  List<int> get tags;

  factory CborValue._fromObject(
    Object? object, {
    required bool dateTimeEpoch,
    required Object? Function(dynamic object) toEncodable,
    Set<Object>? cycleCheck,
  }) {
    if (object == null) {
      return CborNull();
    } else if (object is CborValue) {
      return object;
    } else if (object is int) {
      return CborSmallInt(object);
    } else if (object is BigInt) {
      return CborInt(object);
    } else if (object is double) {
      return CborFloat(object);
    } else if (object is bool) {
      return CborBool(object);
    } else if (object is Uint8List) {
      return CborBytes(object);
    } else if (object is String) {
      return CborString(object);
    } else if (object is DateTime) {
      if (!dateTimeEpoch) {
        return CborDateTimeString(object);
      } else if (object.millisecondsSinceEpoch % CborConstants.milliseconds == 0) {
        return CborDateTimeInt.fromSecondsSinceEpoch(object.millisecondsSinceEpoch ~/ CborConstants.milliseconds);
      } else {
        return CborDateTimeFloat.fromSecondsSinceEpoch(object.millisecondsSinceEpoch / CborConstants.milliseconds);
      }
    } else if (object is Uri) {
      return CborUri(object);
    } else if (object is Iterable) {
      cycleCheck ??= {};

      if (!cycleCheck.add(object)) {
        throw CborCyclicError(object);
      }

      final value = CborList.of(
        object.map(
          (v) => CborValue._fromObject(v, dateTimeEpoch: dateTimeEpoch, toEncodable: toEncodable, cycleCheck: cycleCheck),
        ),
      );

      cycleCheck.remove(object);

      return value;
    } else if (object is Map) {
      cycleCheck ??= {};

      if (!cycleCheck.add(object)) {
        throw CborCyclicError(object);
      }

      final value = CborMap.fromEntries(
        object.entries.map(
          (entry) => MapEntry(
            CborValue._fromObject(
              entry.key,
              dateTimeEpoch: dateTimeEpoch,
              toEncodable: toEncodable,
              cycleCheck: cycleCheck,
            ),
            CborValue._fromObject(
              entry.value,
              dateTimeEpoch: dateTimeEpoch,
              toEncodable: toEncodable,
              cycleCheck: cycleCheck,
            ),
          ),
        ),
      );

      cycleCheck.remove(object);

      return value;
    } else {
      return CborValue._fromObject(
        toEncodable(object),
        dateTimeEpoch: dateTimeEpoch,
        toEncodable: toEncodable,
        cycleCheck: cycleCheck,
      );
    }
  }

  /// Transform the [Object] into a CborValue.
  ///
  /// Throws [CborCyclicError] if cyclic references exist inside [object].
  ///
  /// The object is transformed according to the following relations.
  ///
  /// | Input                     | Output                      |
  /// |---------------------------|-----------------------------|
  /// | `null`                    | [CborNull]                  |
  /// | [CborValue]               | [CborValue] (unchanged)     |
  /// | [double]                  | [CborFloat]                 |
  /// | [int]                     | [CborSmallInt]              |
  /// | [BigInt]                  | [CborInt]                   |
  /// | [bool]                    | [CborBool]                  |
  /// | [Uint8List]               | [CborBytes]                 |
  /// | [String]                  | [CborString]                |
  /// | [DateTime]                | [CborDateTime]              |
  /// | [Uri]                     | [CborUri]                   |
  /// | [Iterable]                | [CborList]                  |
  /// | [Map]                     | [CborMap]                   |
  ///
  /// If [dateTimeEpoch] is `false`, [DateTime] is transformed into
  /// [CborDateTimeString], and otherwise into [CborDateTimeInt] or
  /// [CborDateTimeFloat] depending on the sub-second resolution.
  ///
  /// The [toEncodable] function is used during encoding. It is invoked for
  /// values that are not directly encodable to a [CborValue]. The
  /// function must return an object that is directly encodable. The elements of
  /// a returned list and values of a returned map do not need to be directly
  /// encodable, and if they aren't, `toEncodable` will be used on them as well.
  /// Please notice that it is possible to cause an infinite recursive regress
  /// in this way, by effectively creating an infinite data structure through
  /// repeated call to `toEncodable`.
  ///
  /// If [toEncodable] is omitted, it defaults to a function that returns the
  /// result of calling `.toCbor()` on the unencodable object.
  factory CborValue(Object? object, {bool dateTimeEpoch = false, Object? Function(dynamic object)? toEncodable}) =>
      CborValue._fromObject(object, dateTimeEpoch: dateTimeEpoch, toEncodable: toEncodable ?? (object) => object.toCbor());

  /// Transforms the CborValue into a Dart object.
  ///
  /// Throws [CborCyclicError] if cyclic references exist inside `this`.
  ///
  /// Parsing may throw [FormatException].
  ///
  /// The object is transformed according to the following relations.
  ///
  /// | Input                     | Output                      |
  /// |---------------------------|-----------------------------|
  /// | [CborSimpleValue]         | [int]                       |
  /// | [CborNull]                | `null`                      |
  /// | [CborUndefined]           | `null`                      |
  /// | [CborBool]                | [bool]                      |
  /// | [CborFloat]               | [double]                    |
  /// | [CborDateTimeFloat]       | if ([parseDateTime]) [DateTime] else [double] |
  /// | [CborInt]                 | [int] or [BigInt]           |
  /// | [CborDateTimeInt]         | if ([parseDateTime]) [DateTime] else [int] |
  /// | [CborBytes]               | [List<int>]                 |
  /// | [CborBigInt]              | [BigInt]                    |
  /// | [CborString]              | [String]                    |
  /// | [CborDateTimeString]      | if ([parseDateTime]) [DateTime] else [String] |
  /// | [CborUri]                 | if ([parseUri]) [Uri] else [String] |
  /// | [CborBase64]              | if ([decodeBase64]) [List<int>] else [String] |
  /// | [CborBase64Url]           | if ([decodeBase64]) [List<int>] else [String] |
  /// | [CborRegex]               | [String]                    |
  /// | [CborMime]                | [String]                    |
  /// | [CborList]                | [List]                      |
  /// | [CborDecimalFraction]     | `[int exponent, BigInt mantissa]` |
  /// | [CborBigFloat]            | `[int exponent, BigInt mantissa]` |
  /// | [CborMap]                 | [Map]                       |
  Object? toObject({
    bool parseDateTime = true,
    bool parseUri = true,
    bool decodeBase64 = false,
    bool allowMalformedUtf8 = false,
  });

  /// Transform this into a JSON encodable value.
  ///
  /// [substituteValue] will be used for values that cannot be encoded, such
  /// as [double.infinity], [double.nan], [CborUndefined].
  ///
  /// If the keys for a map are not strings, they are encoded recursively
  /// as JSON, and the string is used.
  Object? toJson({Object? substituteValue, bool allowMalformedUtf8 = false});

  @internal
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o);

  @internal
  void encode(EncodeSink sink);

  @internal
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o);
}

/// A CBOR datetime.
abstract class CborDateTime implements CborValue {
  /// Converts the value to [DateTime], throwing [FormatException] if fails.
  DateTime toDateTime();
}
