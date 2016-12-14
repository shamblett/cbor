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

/// Get the handle to the binary data
///
/// Definite items only. Modifying the data is allowed. In that case, the caller takes
/// responsibility for the effect on items this item might be a part of
///
/// @param item A definite byte string
/// @return The binary data.
Uint8List cborBytestringHandle(CborItem item) {
  assert(cborIsaBytestring(item));
  return item.uintData;
}

/// Set the handle to the binary data
///
/// @param item A definite byte string
/// @param data The data block.
/// @param length Length of the data block
void cborBytestringSetHandle(CborItem item, Uint8List data, int length) {
  assert(cborIsaBytestring(item));
  assert(cborBytestringIsDefinite(item));
  item.uintData = data;
  item.metadata.bytestringMetadata.length = length;
}

/// Get the size of a bytestring
///
/// @param item A indefinite bytestring
/// @return The size
int cborBytestringSize(CborItem item) {
  assert(cborIsaBytestring(item));
  assert(cborBytestringIsIndefinite(item));
  return item.uintData.length;
}

/// Appends a chunk to the bytestring
///
/// Indefinite byte strings only.
/// @param item An indefinite byte string
/// @param chunk A definite byte string
void cborBytestringAddChunk(CborItem item, CborItem chunk) {
  assert(cborIsaBytestring(item));
  assert(cborBytestringIsIndefinite(item));
  item.uintData.addAll(chunk.uintData);
}

/// Creates a new definite byte string
///
/// The handle is initialized to `NULL` and length to 0
///
/// @return **new** definite bytestring.
CborItem cborNewDefiniteBytestring() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeBytestring;
  item.metadata = new CborItemMetadata();
  item.metadata.bytestringMetadata.type = CborDstMetadata.cborMetaDataDefinate;
  item.metadata.bytestringMetadata.length = 0;
  return item;
}

/// Creates a new indefinite byte string
///
/// The handle is initialized to `NULL` and length to 0
///
/// @return **new** indefinite bytestring.
CborItem cborNewIndefiniteBytestring() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeBytestring;
  item.metadata = new CborItemMetadata();
  item.metadata.bytestringMetadata.type =
      CborDstMetadata.cborMetaDataIndefinate;
  item.metadata.bytestringMetadata.length = 0;
  return item;
}
