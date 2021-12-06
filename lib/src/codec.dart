import 'dart:convert';

import 'package:cbor/cbor.dart';

/// A constant instance of a CBOR codec, using default parameters.
const CborCodec cbor = CborCodec();

/// A CBOR encoder and decoder.
///
/// For exceptions [decode] may throw, see [CborDecoder].
class CborCodec extends Codec<CborValue, List<int>> {
  /// Create a CBOR codec.
  ///
  /// If [strict], [decoder] will be in strict mode.
  ///
  /// Currently strict mode is on by default, but this may change in the
  /// future. If you want to rely on this, explicitly add the argument.
  const CborCodec({bool strict = true})
      : decoder = strict
            ? const CborDecoder(strict: true)
            : const CborDecoder(strict: false);

  @override
  final CborDecoder decoder;

  @override
  Converter<CborValue, List<int>> get encoder => throw UnimplementedError();
}
