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
  item.mapData = new List<CborPair>(size);
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
  item.mapData = new List<CborPair>();
  item.metadata.mapMetadata.type = CborDstMetadata.cborMetaDataIndefinate;
  item.metadata.mapMetadata.endPtr = 0;
  return item;
}

/// Get the pairs storage
///
/// @param item A map
/// @return Array of #cbor_map_size pairs. Manipulation is possible as long as references remain valid.
List<CborPair> cborMapHandle(CborItem item) {
  assert(cborIsaMap(item));
  return item.mapData;
}

/// Is this map definite?
///
/// @param item A map
/// @return Is this map definite?
bool cborMapIsDefinite(CborItem item) {
  assert(cborIsaMap(item));
  return item.metadata.mapMetadata.type == CborDstMetadata.cborMetaDataDefinate;
}

/// Is this map indefinite?
///
/// @param item A map
/// @return Is this map indefinite?
bool cborMapIsIndefinite(CborItem item) {
  assert(cborIsaMap(item));
  return item.metadata.mapMetadata.type ==
      CborDstMetadata.cborMetaDataIndefinate;
}

/// Add a key to the map
///
/// Sets the value to `NULL`. Internal API.
///
/// @param item A map
/// @param key The key
/// @return `true` on success, `false` if the preallcoated storage is full
bool _cborMapAddKey(CborItem item, CborItem key) {
  assert(cborIsaMap(item));
  CborMapMetadata metadata = item.metadata.mapMetadata;
  if (cborMapIsDefinite(item)) {
    List<CborPair> data = cborMapHandle(item);
    if (metadata.endPtr >= metadata.allocated) {
      /* Don't realloc definite preallocated map */
      return false;
    }
    data[metadata.endPtr].key = key;
    data[metadata.endPtr].value = null;
    metadata.endPtr++;
    item.mapData = data;
  } else {
    if (metadata.endPtr >= metadata.allocated) {
      CborPair newData = new CborPair();
      newData.key = key;
      item.mapData.add(newData);
      metadata.endPtr++;
      metadata.allocated++;
    } else {
      List<CborPair> data = cborMapHandle(item);
      data[metadata.endPtr].key = key;
      data[metadata.endPtr].value = null;
      metadata.endPtr++;
      item.mapData = data;
    }
  }
  key.refcount++;
  return true;
}

/// Add a value to the map
///
/// Assumes that #_cbor_map_add_key has been called. Internal API.
///
/// @param item A map
/// @param key The value
/// @return `true` on success, `false` if the preallcoated storage is full
bool _cborMapAddValue(CborItem item, CborItem value) {
  assert(cborIsaMap(item));
  value.refcount++;
  cborMapHandle(item)[item.metadata.mapMetadata.endPtr].value = value;
  return true;
}

/// Add a pair to the map
///
/// For definite maps, items can only be added to the preallocated space. For indefinite
/// maps, the storage will be expanded as needed
///
/// @param item A map
/// @param pair The key-value pair to add
/// @return `true` on success, `false` if the preallcoated storage is full
bool cborMapAdd(CborItem item, CborPair pair) {
  assert(cborIsaMap(item));
  if (!_cborMapAddKey(item, pair.key)) return false;
  return _cborMapAddValue(item, pair.value);
}
