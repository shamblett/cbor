/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* Integer (uints and negints) manipulation
* ============================================================================
*/

/// Queries the integer width
///
/// @param item positive or negative integer item
/// @return the width
CborIntWidth cborIntGetWidth(CborItem item) {
  assert(cborIsInt(item));
  return item.metadata.intMetadata.width;
}


/// Extracts the integer value
///
/// @param item positive or negative integer
/// @return the value
int cborGetUint8(CborItem item) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt8);
  return item.intData;
}

/// Extracts the integer value
///
/// @param item positive or negative integer
/// @return the value
int cborGetUint16(CborItem item) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt16);
  return item.intData;
}

/// Extracts the integer value
///
/// @param item positive or negative integer
/// @return the value
int cborGetUint32(CborItem item) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt32);
  return item.intData;
}

/// Extracts the integer value
///
/// @param item positive or negative integer
/// @return the value
int cborGetUint64(CborItem item) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt64);
  return item.intData;
}
