/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Specifies the Major type of ::cbor_item_t
enum CborType {
  cborTypeUint, // 0 - positive integers
  cborTypeNegint, // 1 - negative integers
  cborTypeBytestring, // 2 - byte strings
  cborTypeString, // 3 - strings
  cborTypeArray, // 4 - arrays
  cborTypeMap, // 5 - maps
  cborTypeTag, // 6 - tags
  cborTypeFloatCtrl // 7 - decimals and special values (true, false, nil, ...)
}

/// Possible decoding errors
enum CborErrorCode {
  cborErrNone,
  cborErrNotEnoughData,
  cborErrNodata,
  cborErrMalformated,
  cborErrSyntaxError // Stack parsing algorithm failed
}

// Possible widths of #CBOR_TYPE_UINT items
enum CborIntWidth { cborInt8, cborInt16, cborInt32, cborInt64 }

/// Possible widths of #CBOR_TYPE_FLOAT_CTRL items
enum CborFloatWidth {
  cborFloat0, // Internal use - ctrl and special values
  cborFloat16, // Half float
  cborFloat32, // Single float
  cborFloat64 // Double
}

/// Metadata for dynamically sized types
enum CborDstMetadata { cborMetaDataDefinate, cborMetaDataIndefinate }

/// Semantic mapping for CTRL simple values
enum ECborCtrl {
  cborCtrlNone,
  cborCtrlFalse,
  cborCtrlTrue,
  cborCtrlUndef,
  cborCtrlNull
}

final Map<int, ECborCtrl> cborCtrl = {
  0: ECborCtrl.cborCtrlNone,
  20: ECborCtrl.cborCtrlFalse,
  21: ECborCtrl.cborCtrlTrue,
  23: ECborCtrl.cborCtrlUndef,
  22: ECborCtrl.cborCtrlNull
};

/// Integers specific metadata
class CborIntMetadata {
  CborIntWidth width;
}

/// Bytestrings specific metadata
class CborBytestringMetadata {
  int length;
  CborDstMetadata type;
}

/// Strings specific metadata
class CborStringMetadata {
  int length;
  int codepointCount; // Sum of chunks' codepoint_counts for indefinite strings
  CborDstMetadata type;
}

/// Arrays specific metadata
class CborArrayMetadata {
  int allocated;
  int endPtr;
  CborDstMetadata type;
}

/// Maps specific metadata
class CborMapMetadata {
  int allocated;
  int endPtr;
  CborDstMetadata type;
}

/// Tag specific metadata
class CborTagMetadata {
  CborItem taggedItem;
  int value;
}

/// Floats specific metadata - includes CTRL values */
class CborFloatCtrlMetadata {
  CborFloatWidth width;
  int ctrl;
}

//// Union of metadata across all possible types - discriminated in #CborItem */
class CborItemMetadata {
  CborIntMetadata intMetadata;
  CborBytestringMetadata bytestringMetadata;
  CborStringMetadata stringMetadata;
  CborArrayMetadata arrayMetadata;
  CborMapMetadata mapMetadata;
  CborTagMetadata tagMetadata;
  CborFloatCtrlMetadata floatCtrlMetadata;
}

/// The item handle
class CborItem {
  /// Discriminated by type
  CborItemMetadata metadata;

  /// Reference count - initialize to 0
  int refcount;

  /// Major type discriminator
  CborType type;

  /// Raw data block - interpretation depends on metadata */
  Uint8List data;
}

/// Defines cbor_item#data structure for indefinite strings and bytestrings
class CborIndefiniteStringData {
  int chunkCount;
  int chunkCapacity;
  CborItem chunks;
}

/// High-level decoding error
class CborError {
  /// Aproximate position
  int position;

  /// Description
  CborErrorCode code;
}

/// Simple pair of items for use in maps
class CborPair {
  CborItem key, value;
}

/// High-level decoding result
class CborLoadResult {
  /// Error indicator
  CborError error;

  /// Number of bytes read
  int read;
}

/// Streaming decoder result - status
enum CborDecoderStatus {
  cborDecoderFinished, // OK, finished
  cborDecoderNedata, // Not enough data - mismatch with MTB
  cborDecoderEbuffer, // Buffer manipulation problem
  cborDecoderError // Malformed or reserved MTB/value
}

/// Streaming decoder result
class CborDecoderResult {
  /// Bytes read
  int read;

  /// The result
  CborDecoderStatus status;
}
