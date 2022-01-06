/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
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
/// If the input is malformed, the decoder will throw [CborMalformedException].
///
/// The decoder will not throw if the input is invalid but well-formed.
/// However, operations on [CborValue] may throw if invalid data is used.
///
/// This decoder supports [startChunkedConversion] and can therefore be
/// used as a stream transformer. The decoder operates over a CBOR sequence
/// in this mode.
class CborDecoder extends Converter<List<int>, CborValue> {
  /// Create a CBOR decoder.
  const CborDecoder();

  /// Converts [input] and returns the result of the conversion.
  ///
  /// If the input does not contain a single CBOR item, [FormatException] will
  /// be thrown.
  @override
  CborValue convert(List<int> input) {
    CborValue? value;

    startChunkedConversion(ChunkedConversionSink.withCallback((values) {
      if (values.isEmpty) {
        throw FormatException('Expected at least one CBOR value.');
      }
      if (values.length > 1) {
        throw FormatException('Expected at most one CBOR value.');
      }

      value = values.single;
    }))
      ..add(input)
      ..close();

    return value!;
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<CborValue> sink) =>
      RawSink(RawSinkTagged(CborSink(sink)));
}
