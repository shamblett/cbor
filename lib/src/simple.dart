/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'utils/utils.dart';

/// A simple encoder for CBOR.
///
/// Conversion is done with [CborValue.CborValue].
/// Check the [CborValue.CborValue] documentation for supported values.
///
/// If cyclic references are found while encoding, a [CborCyclicError] will
/// be thrown.
class CborSimpleEncoder extends Converter<Object?, List<int>> {
  const CborSimpleEncoder({
    bool dateTimeEpoch = false,
    Object? Function(dynamic object)? toEncodable,
  })  : _toEncodable = toEncodable,
        _dateTimeEpoch = dateTimeEpoch;

  final Object? Function(dynamic object)? _toEncodable;
  final bool _dateTimeEpoch;

  @override
  List<int> convert(Object? input) {
    return cbor.encode(CborValue(input,
        dateTimeEpoch: _dateTimeEpoch, toEncodable: _toEncodable));
  }

  @override
  Sink<Object?> startChunkedConversion(Sink<List<int>> sink) {
    return cbor.encoder.startChunkedConversion(sink).map((object) => CborValue(
        object,
        dateTimeEpoch: _dateTimeEpoch,
        toEncodable: _toEncodable));
  }
}

/// A simple decoder for CBOR.
///
/// May throw [FormatException] if the input is invalid.
class CborSimpleDecoder extends Converter<List<int>, Object?> {
  /// Create a CBOR decoder.
  ///
  /// See the docs of [CborValue.toObject] to see how CBOR values translate
  /// into objects.
  const CborSimpleDecoder({
    bool parseDateTime = true,
    bool decodeBase64 = true,
    bool parseUri = true,
  })  : _parseDateTime = parseDateTime,
        _decodeBase64 = decodeBase64,
        _parseUri = parseUri;

  final bool _parseDateTime;
  final bool _decodeBase64;
  final bool _parseUri;

  @override
  Object? convert(List<int> input) {
    return const CborDecoder().convert(input).toObject(
          parseUri: _parseUri,
          parseDateTime: _parseDateTime,
          decodeBase64: _decodeBase64,
        );
  }

  @override
  Sink<List<int>> startChunkedConversion(Sink<Object?> sink) {
    return const CborDecoder()
        .startChunkedConversion(sink.map((object) => object.toObject(
              parseUri: _parseUri,
              parseDateTime: _parseDateTime,
              decodeBase64: _decodeBase64,
            )));
  }
}

/// A simple codec for CBOR, using [CborSimpleEncoder] and [CborSimpleDecoder].
///
/// To see how CBOR values are transformed from and into objects, verify the
/// documentation of both [CborValue.CborValue] and [CborValue.toObject].
class CborSimpleCodec extends Codec<Object?, List<int>> {
  /// Create a CBOR simple codec.
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
  const CborSimpleCodec({
    bool encodeDateTimeEpoch = false,
    bool parseDateTime = true,
    bool decodeBase64 = true,
    bool parseUri = true,
    Object? Function(dynamic object)? toEncodable,
  })  : _decodeBase64 = decodeBase64,
        _encodeDateTimeEpoch = encodeDateTimeEpoch,
        _parseUri = parseUri,
        _parseDateTime = parseDateTime,
        _toEncodable = toEncodable;

  final bool _encodeDateTimeEpoch;
  final bool _decodeBase64;
  final bool _parseUri;
  final bool _parseDateTime;
  final Object? Function(dynamic object)? _toEncodable;

  @override
  CborSimpleEncoder get encoder {
    return CborSimpleEncoder(
      dateTimeEpoch: _encodeDateTimeEpoch,
      toEncodable: _toEncodable,
    );
  }

  @override
  CborSimpleDecoder get decoder {
    return CborSimpleDecoder(
      decodeBase64: _decodeBase64,
      parseUri: _parseUri,
      parseDateTime: _parseDateTime,
    );
  }

  @override
  Object? decode(
    List<int> input, {
    bool? parseDateTime,
    bool? decodeBase64,
    bool? parseUri,
  }) {
    parseDateTime ??= _parseDateTime;
    decodeBase64 ??= _decodeBase64;
    parseUri ??= _parseUri;

    return CborSimpleDecoder(
      parseDateTime: parseDateTime,
      parseUri: parseUri,
      decodeBase64: decodeBase64,
    ).convert(input);
  }

  @override
  List<int> encode(
    Object? value, {
    bool? dateTimeEpoch,
    Object? Function(dynamic object)? toEncodable,
  }) {
    toEncodable ??= _toEncodable;
    dateTimeEpoch ??= _encodeDateTimeEpoch;

    return CborSimpleEncoder(
      dateTimeEpoch: dateTimeEpoch,
      toEncodable: toEncodable,
    ).convert(value);
  }
}
