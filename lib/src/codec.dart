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
  const CborCodec({bool strict = true}) : _strict = strict;

  final bool _strict;

  @override
  CborDecoder get decoder {
    if (_strict) {
      return const CborDecoder(strict: true);
    } else {
      return const CborDecoder(strict: false);
    }
  }

  @override
  final CborEncoder encoder = const CborEncoder();

  @override
  CborValue decode(List<int> input, {bool? strict}) {
    strict ??= _strict;

    return CborDecoder(strict: strict).convert(input);
  }
}

/// Alias for `cbor.encode`.
List<int> cborEncode(CborValue value) {
  return cbor.encode(value);
}

/// Alias for `cbor.decode`.
CborValue cborDecode(List<int> value) {
  return cbor.decode(value);
}
