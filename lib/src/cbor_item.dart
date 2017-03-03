/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The CBOR data item class.
/// Objects of this class are produced by the standard
/// listener class.
class CborItem {

  /// The item data
  dynamic data = null;

  /// The item type, one of the major types.
  int type = majorTypeNotSet;

  /// Indefinite indicator
  bool indefinite = false;
}