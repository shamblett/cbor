/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The Dart types an item can have.
enum dartTypes {
  dtInt,
  dtDouble,
  dtMap,
  dtList,
  dtBuffer,
  dtNull,
  dtString,
  dtBool,
  dtUndefined,
  dtNone
}

/// If the type is dtBuffer or dtString a hint at what the
/// data may contain.
enum dataHints {
  base64Url,
  base64,
  base16,
  encodedCBOR,
  uri,
  unassigned,
  selfDescCBOR,
  mime,
  regex,
  bigfloat,
  decFraction,
  error,
  none,
  dateTimeString,
  dateTimeEpoch
}

/// The CBOR Dart item class.
/// Objects of this class are produced by the standard
/// stack class.
class DartItem {
  /// The item data
  dynamic data = null;

  /// Target size is what we expect the size to
  /// be.
  int targetSize = 0;

  /// The item type, one of the major types.
  dartTypes type = dartTypes.dtNone;

  /// Is the type complete, for maps, lists
  /// and buffers.
  bool complete = false;

  /// Hint for buffer or string types
  dataHints hint = dataHints.none;

  /// Actual size
  int size() {
    return data.length;
  }
}
