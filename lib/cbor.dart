/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

/// Advanced API for CBOR.
///
/// # Quick reference
///
/// ## Decoders and encoders
///
/// Between bytes and [CborValue]:
///
/// * [CborCodec]
///   * [CborDecoder]
///   * [CborEncoder]
///   * [cbor]
///   * [cborDecode]
///   * [cborEncode]
///
/// Between bytes and objects:
///
/// * [CborSimpleCodec]
///   * [CborSimpleDecoder]
///   * [CborSimpleEncoder]
///
/// To JSON from [CborValue]:
///
/// * [CborJsonEncoder]
///
/// ## Pretty printing
///
/// * [cborPrettyPrint]
///
/// ## Values
///
/// Super type:
///
/// * [CborValue]
///
/// Interfaces:
///
/// * [CborDateTime]
///   * Implementers:
///   * [CborDateTimeString]
///   * [CborDateTimeInt]
///   * [CborDateTimeFloat]
/// * [CborInt]
///   * Implementers:
///   * [CborSmallInt]
///   * [CborBigInt]
///   * [CborDateTimeInt]
///
/// Major types:
///
/// * [CborBytes]
/// * [CborString]
/// * [CborFloat]
/// * [CborMap]
/// * [CborList]
/// * [CborInt]
///   * [CborSmallInt]
/// * [CborSimpleValue]
///   * [CborNull]
///   * [CborBool]
///   * [CborUndefined]
///
/// Tag based:
///
/// * [CborDateTimeInt]
/// * [CborBigInt]
/// * [CborDateTimeString]
/// * [CborBase64]
/// * [CborBase64Url]
/// * [CborMime]
/// * [CborRegex]
/// * [CborDateTimeFloat]
/// * [CborDecimalFraction]
/// * [CborRationalNumber]
/// * [CborBigFloat]
library cbor;

export 'src/codec.dart';
export 'src/decoder/decoder.dart';
export 'src/decoder/pretty_print.dart';
export 'src/encoder/encoder.dart';
export 'src/error.dart';
export 'src/json.dart';
export 'src/simple.dart';
export 'src/value/value.dart';
