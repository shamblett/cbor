/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

// How the decoder works:
//
// Data in form of bytes is inserted into `Reader`.
//
// The `Reader` then supplies a `Header` to a `BuilderReader`, which will
// return a `Builder` when the `Header` is supplied.
//
// Then, the `Builder` can `poll` to read bytes, and when enough bytes are
// read it will return a `CborValue` - a list or map builder will contain
// builders inside themselves to build their items.
//
// At any point, if the `Reader` has not enough bytes, `null` is returned.
// The builder can store state about the previous bytes to allow
// streamed decoding. In special, a list or map can store the items which
// have been built so far.

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'builder.dart';

/// A CBOR decoder.
///
/// The CBOR decoder will always throw [FormatException] when:
///
/// * An invalid value for additional info is provided, or
/// * The CBOR is incomplete, or
/// * An indefinite length byte string contains any item other than a byte string, or
/// * An indefinite length string contains any item other than a string.
///
/// If the CBOR decoder is using [strict] mode, it will throw [FormatException]
/// when:
///
/// * A string is not UTF-8, or
/// * A tag is found with the incorrect type, or
/// * A CBOR `break` is encountered outside a indefinite length item, or
/// * An indefinite byte string or string contains any item other than
///   a definite length byte string or string, respectively, or
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
  /// Will throw [FormatException] if input contains anything other than a
  /// single CBOR value.
  @override
  CborValue convert(List<int> input) {
    final reader = BuilderReader(strict);

    reader.add(input);
    final value = reader.read()?.poll();

    if (value == null) {
      throw FormatException('Expected at least one CBOR value.');
    }

    if (reader.remaniningBytes != 0) {
      throw FormatException('Expected at most one CBOR value.');
    }

    return value;
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<CborValue> sink) {
    return _ChunkedConversion(strict, sink);
  }
}

class _ChunkedConversion extends Sink<List<int>> {
  _ChunkedConversion(this.strict, this.sink) : reader = BuilderReader(strict);

  final Sink<CborValue> sink;
  final BuilderReader reader;
  Builder? builder;
  final bool strict;

  @override
  void add(List<int> data) {
    reader.add(data);
    builder ??= reader.read();

    final value = builder?.poll();

    if (value != null) {
      builder = null;
      sink.add(value);
    }
  }

  @override
  void close() {
    if (reader.remaniningBytes != 0) {
      throw FormatException('Incomplete CBOR value');
    }
  }
}
