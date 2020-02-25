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
  dtBigInt,
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
/// stack listener class by the decode process.
class DartItem {
  /// The item data.
  dynamic data;

  /// Target size is what we expect the size to
  /// be.
  int targetSize = 0;

  /// The item type, one of the major types.
  dartTypes type = dartTypes.dtNone;

  /// Is the type complete, i,e is its actual size
  /// equql to its target size.
  bool complete = false;

  /// Possible type usage hint for buffer or string types.
  /// See RFC 7049 for more details. Also used to indicate
  /// an error condition in which case the data field will
  /// contain a string representation of the error.
  dataHints hint = dataHints.none;

  /// Actual size
  int size() => data.length;

  /// Awaiting a map key for Map types.
  bool awaitingMapKey = false;

  /// Awaiting a map value for Map types.
  bool awaitingMapValue = false;

  /// The last key value inserted into a map
  dynamic lastMapKey;

  /// Ignore indicator. Used to indicate the item
  /// should be ignored during stack traversal, the
  /// item has been used as a partial build area for
  /// another stack item for instance.
  bool ignore = false;

  /// Helper functions

  bool isIncompleteList() {
    if ((type == dartTypes.dtList) && !complete) {
      return true;
    }
    return false;
  }

  bool isIncompleteMap() {
    if ((type == dartTypes.dtMap) && !complete) {
      return true;
    }
    return false;
  }

  bool awaitingMapEntry() {
    if (awaitingMapValue || awaitingMapKey) {
      return true;
    }
    return false;
  }
}
