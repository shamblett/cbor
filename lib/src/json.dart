/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'utils/utils.dart';

/// Encodes CBOR into JSON.
///
/// If the keys for a map are not strings, they are encoded recursively
/// as JSON, and the string is used.
class CborJsonEncoder extends Converter<CborValue, String> {
  /// [substituteValue] will be used for values that cannot be encoded, such
  /// as [double.infinity], [double.nan], [CborUndefined].
  const CborJsonEncoder({
    Object? substituteValue,
    bool allowMalformedUtf8 = false,
  })  : _allowMalformedUtf8 = allowMalformedUtf8,
        _substituteValue = substituteValue;

  final Object? _substituteValue;
  final bool _allowMalformedUtf8;

  @override
  String convert(CborValue input) {
    return json.encode(input.toJson(
      substituteValue: _substituteValue,
      allowMalformedUtf8: _allowMalformedUtf8,
    ));
  }

  @override
  Sink<CborValue> startChunkedConversion(Sink<String> input) {
    return const JsonEncoder()
        .startChunkedConversion(input)
        .map((x) => x.toJson(
              substituteValue: _substituteValue,
              allowMalformedUtf8: _allowMalformedUtf8,
            ));
  }
}
