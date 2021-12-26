/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import 'internal.dart';

export 'bytes.dart';
export 'map.dart';
export 'double.dart';
export 'int.dart';
export 'list.dart';
export 'simple_value.dart';
export 'string.dart';

/// Hint for the content of something.
@sealed
class CborTag {
  CborTag._();

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
  factory CborValue._fromObject(
    Object? object,
    bool dateTimeEpoch,
    Set<Object> cycleCheck,
  ) {
    if (object == null) {
      return CborNull();
    } else if (object is CborValue) {
      return object;
    } else if (object is double) {
      return CborFloat(object);
    } else if (object is int) {
      return CborSmallInt(object);
    } else if (object is BigInt) {
      return CborInt(object);
    } else if (object is bool) {
      return CborBool(object);
    } else if (object is Uint8List) {
      return CborBytes(object);
    } else if (object is String) {
      return CborString(object);
    } else if (object is DateTime) {
      if (!dateTimeEpoch) {
        return CborDateTimeString(object);
      } else if (object.millisecondsSinceEpoch % 1000 == 0) {
        return CborDateTimeInt.fromSecondsSinceEpoch(
            object.millisecondsSinceEpoch ~/ 1000);
      } else {
        return CborDateTimeFloat.fromSecondsSinceEpoch(
            object.millisecondsSinceEpoch / 1000);
      }
    } else if (object is Uri) {
      return CborUri(object);
    } else if (object is Iterable) {
      if (!cycleCheck.add(object)) {
        throw CborCyclicError(object);
      }

      final value = CborList.of(object
          .map((v) => CborValue._fromObject(v, dateTimeEpoch, cycleCheck)));

      cycleCheck.remove(object);

      return value;
    } else if (object is Map) {
      if (!cycleCheck.add(object)) {
        throw CborCyclicError(object);
      }

      final value = CborMap.fromEntries(object.entries.map(
        (entry) => MapEntry(
          CborValue._fromObject(entry.key, dateTimeEpoch, cycleCheck),
          CborValue._fromObject(entry.value, dateTimeEpoch, cycleCheck),
        ),
      ));

      cycleCheck.remove(object);

      return value;
    } else {
      throw TypeError();
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
  factory CborValue(
    Object? object, {
    bool dateTimeEpoch = false,
  }) =>
      CborValue._fromObject(object, dateTimeEpoch, {});

  /// Additional tags provided to the value.
  List<int> get tags;

  /// Hint to a expected conversion when converting to JSON.
  int? get expectedConversion;

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
  });

  /// <nodoc>
  @internal
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o);

  /// <nodoc>
  @internal
  void encode(EncodeSink sink);
}

/// A CBOR datetime.
abstract class CborDateTime with CborValueMixin implements CborValue {
  /// Converts the value to [DateTime], throwing [FormatException] if fails.
  DateTime toDateTime();
}
