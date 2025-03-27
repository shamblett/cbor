/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';

/// A constant instance of a CBOR codec, using default parameters.
const CborCodec cbor = CborCodec();

/// A CBOR encoder and decoder.
///
/// For exceptions [decode] may throw, see [CborDecoder].
class CborCodec extends Codec<CborValue, List<int>> {

  @override
  final CborDecoder decoder = const CborDecoder();
  @override
  final CborEncoder encoder = const CborEncoder();

  /// Create a CBOR codec.
  const CborCodec();

}

/// Alias for `cbor.encode`.
List<int> cborEncode(CborValue value) {
  return cbor.encode(value);
}

/// Alias for `cbor.decode`.
CborValue cborDecode(List<int> value) {
  return cbor.decode(value);
}
