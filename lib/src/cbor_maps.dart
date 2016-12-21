/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* Map manipulation
* ============================================================================
*/

/// Get the number of pairs
///
/// @param item A map
/// @return The number of pairs
int cborMapSize(CborItem item) {
  assert(cborIsaMap(item));
  return item.metadata.mapMetadata.endPtr;
}

/// Get the size of the allocated storage
///
/// @param item A map
/// @return Allocated storage size (as the number of #cbor_pair items)
int cborMapAllocated(CborItem item) {
  assert(cborIsaMap(item));
  return item.metadata.mapMetadata.allocated;
}

/// Create a new definite map
///
/// @param size The number of slots to preallocate
/// @return **new** definite map.
CborItem cborNewDefiniteMap(int size) {
  CborItem item = new CborItem();
  item..refcount = 1;
  item.type = CborType.cborTypeMap;
  item.metadata.mapMetadata = new CborMapMetadata();
  item.metadata.mapMetadata.allocated = size;
  item.metadata.mapMetadata.type = CborDstMetadata.cborMetaDataDefinate;
  item.metadata.mapMetadata.endPtr = 0;
  return item;
}

/// Create a new indefinite map
///
/// @return **new** indefinite map.
CborItem cborNewIndefiniteMap() {
  CborItem item = new CborItem();
  item..refcount = 1;
  item.type = CborType.cborTypeMap;
  item.metadata.mapMetadata = new CborMapMetadata();
  item.metadata.mapMetadata.type = CborDstMetadata.cborMetaDataIndefinate;
  item.metadata.mapMetadata.endPtr = 0;
  return item;
}

