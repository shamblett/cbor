/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* Tag manipulation
* ============================================================================
*/

/// Create a new tag
///
/// @param value The tag value. Please consult the tag repository
/// @return **new** tag. Item reference is `NULL`.
CborItem cborNewTag(int value) {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeTag;
  item.metadata.tagMetadata = new CborTagMetadata();
  item.metadata.tagMetadata.value = value;
  item.metadata.tagMetadata.taggedItem = null;
  return item;
}

/// Get the tagged item
///
/// @param item A tag
/// @return  the tagged item
CborItem cborTagItem(CborItem item) {
  assert(cborIsaTag(item));
  return item.metadata.tagMetadata.taggedItem;
}

/// Get the tag value
///
/// @param item A tagged item
/// @return the tagged value
int cborTagValue(CborItem item) {
  assert(cborIsaTag(item));
  return item.metadata.tagMetadata.value;
}

/// Set the tagged item
///
/// @param item A tag
/// @param tagged_item The item to tag
void cborTagSetItem(CborItem item, CborItem taggedItem) {
  assert(cborIsaTag(item));
  taggedItem.refcount++;
  item.metadata.tagMetadata.taggedItem = taggedItem;
}

/// Build a new tag
///
/// @param item The tagee
/// @param value Tag value
/// @return **new** tag item
CborItem cborBuildTag(int value, CborItem item) {
  CborItem res = cborNewTag(value);
  cborTagSetItem(res, item);
  return res;
}
