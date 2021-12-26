/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

// The decoder works with 3 stages
//
// Stage 0: not really decoder stage, utils used for handling bytes.
//
// Stage 1: sort of a lexer, transforms the input into values with
// header and data. a list will be a single item followed by its items.
//
// Stage 2: associate tags with values.
//
// Stage 3: produce final values, using builders that take values until
// it is done. a list builder will be created when a list header is found
// and then will keep taking values until the list is full.

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'stage1.dart';
import 'stage2.dart';
import 'stage3.dart';

/// A CBOR decoder.
///
/// The CBOR decoder will always throw [CborDecodeException] when:
///
/// * An invalid value for additional info is provided, or
/// * The CBOR is incomplete, or
/// * An indefinite length byte string contains any item other than a byte string, or
/// * An indefinite length string contains any item other than a string.
///
/// If the CBOR decoder is using [strict] mode, it will throw [CborDecodeException]
/// when:
///
/// * A string is not UTF-8, or
/// * A tag is found with the incorrect type, or
/// * A CBOR `break` is encountered outside a indefinite length item, or
/// * Incompatible tags are used, or
/// * When taking a tag in consideration, the format of a value is incorrect
///   (for example, a [CborDateTimeString] is not in date time format).
///
/// When not in [strict] mode, these errors will be ignored.
class CborDecoder extends Converter<List<int>, CborValue> {
  /// Create a CBOR decoder.
  ///
  /// Currently strict mode is on by default, but this may change in the
  /// future. If you want to rely on this, explicitly add the argument.
  const CborDecoder({this.strict = true});

  /// If `true`, we are in strict mode. Check [CborDecoder] for its meaning.
  final bool strict;

  /// Converts [input] and returns the result of the conversion.
  ///
  /// Will throw [CborDecodeException] if input contains anything other than a
  /// single CBOR value.
  @override
  CborValue convert(List<int> input) {
    CborValue? value;

    startChunkedConversion(ChunkedConversionSink.withCallback((values) {
      if (values.isEmpty) {
        throw CborDecodeException('Expected at least one CBOR value.');
      }
      if (values.length > 1) {
        throw CborDecodeException('Expected at most one CBOR value.');
      }

      value = values.single;
    }))
      ..add(input)
      ..close();

    return value!;
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<CborValue> sink) =>
      RawSink(RawSinkTagged(CborSink(strict, sink)));
}
