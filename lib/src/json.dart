/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'utils/utils.dart';

/// Encodes CBOR into JSON.
///
/// If the keys for a map are not strings, they are encoded recursively
/// as JSON, and the string is used.
///
/// This encoder supports [startChunkedConversion] and can therefore be
/// used as a stream transformer.
class CborJsonEncoder extends Converter<CborValue, String> {
  /// Create a new CBOR JSON encoder.
  ///
  /// [substituteValue] will be used for values that cannot be encoded, such
  /// as [double.infinity], [double.nan], [CborUndefined]. By default this
  /// is `null`.
  ///
  /// If [allowMalformedUtf8] is `false`, the decoder will
  /// throw [FormatException] when invalid UTF-8 is found. Otherwise,
  /// it will use replacement characters.
  const CborJsonEncoder({
    Object? substituteValue,
    bool allowMalformedUtf8 = false,
  }) : _allowMalformedUtf8 = allowMalformedUtf8,
       _substituteValue = substituteValue;

  final Object? _substituteValue;
  final bool _allowMalformedUtf8;

  @override
  String convert(CborValue input) {
    return json.encode(
      input.toJson(
        substituteValue: _substituteValue,
        allowMalformedUtf8: _allowMalformedUtf8,
      ),
    );
  }

  @override
  Sink<CborValue> startChunkedConversion(Sink<String> sink) {
    return const JsonEncoder()
        .startChunkedConversion(sink)
        .map(
          (x) => x.toJson(
            substituteValue: _substituteValue,
            allowMalformedUtf8: _allowMalformedUtf8,
          ),
        );
  }
}
