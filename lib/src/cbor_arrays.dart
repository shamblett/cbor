/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Get the number of members
///
/// @param item An array
/// @return The number of members
int cborArraySize(CborItem item) {
  assert(cborIsaArray(item));
  return item.metadata.arrayMetadata.endPtr;
}

/// Get the size of the allocated storage
///
/// @param item An array
/// @return The size of the allocated storage (number of items)
int cborArrayAllocated(CborItem item) {
  assert(cborIsaArray(item));
  return item.metadata.arrayMetadata.allocated;
}

/// Get item by index
///
/// @param item An array
/// @param index The index
/// @return The item, or Null in case of boundary violation
CborItem cborArrayGet(CborItem item, int index) {
  return index > item.data.length ? Null : item.data[index];
}

/// Is the array definite?
///
/// @param item An array
/// @return Is the array definite?
bool cborArrayIsDefinite(CborItem item) {
  assert(cborIsaArray(item));
  return item.metadata.arrayMetadata.type ==
      CborDstMetadata.cborMetaDataDefinate;
}

/// Is the array indefinite?
///
/// @param item An array
/// @return Is the array indefinite?
bool cborArrayIsIndefinite(CborItem item) {
  assert(cborIsaArray(item));
  return item.metadata.arrayMetadata.type ==
      CborDstMetadata.cborMetaDataIndefinate;
}

/// Append to the end
///
/// For indefinite items, storage may be reallocated. For definite items, only the
/// preallocated capacity is available.
///
/// @param array An array
/// @param pushee The item to push
/// @return true on success, false on failure
bool cborArrayPush(CborItem array, CborItem pushee) {
  assert(cborIsaArray(array));
  final CborArrayMetadata metadata = array.metadata.arrayMetadata;
  final List<CborItem> data = array.data;
  if (cborArrayIsDefinite(array)) {
    /* Do not reallocate definite arrays */
    if (metadata.endPtr >= metadata.allocated) {
      return false;
    }
    data[metadata.endPtr++] = pushee;
  } else {
    if (metadata.endPtr >= metadata.allocated) {
      array.data.add(pushee);
      metadata.allocated++;
      metadata.endPtr++;
    }
  }
  return true;
}

///Replace item at an index
///
/// The item being replace will be #cbor_decref 'ed.
///
/// @param item An array
/// @param value The item to assign
/// @param index The index, first item is 0.
/// @return true on success, false on allocation failure.
bool cborArrayReplace(CborItem item, int index, CborItem value) {
  if (index >= item.metadata.arrayMetadata.endPtr) return false;
  item.data[index] = value;
  return true;
}

/// Set item by index
///
/// Creating arrays with holes is not possible
///
/// @param item An array
/// @param value The item to assign
/// @param index The index, first item is 0.
/// @return true on success, false on allocation failure.
bool cborArraySet(CborItem item, int index, CborItem value) {
  if (index == item.metadata.arrayMetadata.endPtr) {
    return cborArrayPush(item, value);
  } else if (index < item.metadata.arrayMetadata.endPtr) {
    return cborArrayReplace(item, index, value);
  } else {
    return false;
  }
}

/// Get the array contents
///
/// The items may be reordered and modified as long as references remain consistent.
///
/// @param item An array
/// @return #cbor_array_size items
List<CborItem> cborArrayHandle(CborItem item) {
  assert(cborIsaArray(item));
  return item.data;
}

/// Create new definite array
///
/// @param size Number of slots to preallocate
/// @return **new** array
CborItem cborNewDefiniteArray(int size) {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeArray;
  item.data = new List<CborItem>(size);
  item.metadata.arrayMetadata = new CborArrayMetadata();
  item.metadata.arrayMetadata.type = CborDstMetadata.cborMetaDataDefinate;
  item.metadata.arrayMetadata.allocated = size;
  item.metadata.arrayMetadata.endPtr = 0;
  return item;
}

/// Create new indefinite array
///
/// @return **new** array
CborItem cborNewIndefiniteArray() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeArray;
  item.metadata.arrayMetadata = new CborArrayMetadata();
  item.metadata.arrayMetadata.type = CborDstMetadata.cborMetaDataIndefinate;
  item.metadata.arrayMetadata.allocated = 0;
  item.metadata.arrayMetadata.endPtr = 0;
  return item;
}
