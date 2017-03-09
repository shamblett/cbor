/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

enum dartTypes {
  dtInt,
  dtDouble,
  dtMap,
  dtList,
  dtBuffer,
  dtNull,
  dtString,
  dtBool,
  dtNone
}

/// The CBOR Dart item class.
/// Objects of this class are produced by the standard
/// stack class.
class DartItem {
  /// The item data
  dynamic data = null;

  /// The item type, one of the major types.
  dartTypes type = dartTypes.dtNone;

  /// Is the type cpmplete, for maps, lists
  /// and buffers.
  bool complete = false;
}
