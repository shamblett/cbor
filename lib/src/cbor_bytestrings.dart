/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Returns the length of the binary data
///
/// For definite byte strings only
///
/// @param item a definite bytestring
/// @return length of the binary data. Zero if no chunk has been attached yet
int cborBytestringLength(CborItem item) {
  assert(cborIsaBytestring(item));
  return item.metadata.bytestringMetadata.length;
}

/// Is the byte string definite?
///
/// @param item a byte string
/// @return Is the byte string definite?
///
bool cborBytestringIsDefinite(CborItem item) {
  assert(cborIsaBytestring(item));
  return item.metadata.bytestringMetadata.type ==
      CborDstMetadata.cborMetaDataDefinate;
}

/// Is the byte string indefinite?
///
/// @param item a byte string
/// @return Is the byte string indefinite?
///
bool cborBytestringIsIndefinite(CborItem item) {
  assert(cborIsaBytestring(item));
  return item.metadata.bytestringMetadata.type ==
      CborDstMetadata.cborMetaDataIndefinate;
}


