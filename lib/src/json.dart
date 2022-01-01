import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'utils/utils.dart';

class CborJsonEncoder extends Converter<CborValue, String> {
  const CborJsonEncoder({
    Object? substituteValue,
  }) : _substituteValue = substituteValue;

  final Object? _substituteValue;

  @override
  String convert(CborValue input) {
    return json.encode(input.toJson(substituteValue: _substituteValue));
  }

  @override
  Sink<CborValue> startChunkedConversion(Sink<String> input) {
    return const JsonEncoder()
        .startChunkedConversion(input)
        .map((x) => x.toJson(substituteValue: _substituteValue));
  }
}
