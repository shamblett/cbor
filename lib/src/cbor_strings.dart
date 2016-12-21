/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* String manipulation
* ============================================================================
*/

/// Returns the length of the underlying string
///
/// For definite strings only
///
/// @param item a definite string
/// @return length of the string. Zero if no chunk has been attached yet
int cborStringLength(CborItem item) {
  assert(cborIsaString(item));
  return item.metadata.stringMetadata.length;
}

/// The number of codepoints in this string
///
/// Might differ from length if there are multibyte ones
///
/// @param item A string
/// @return The number of codepoints in this string
int cborStringCodepointCount(CborItem item) {
  assert(cborIsaString(item));
  return item.metadata.stringMetadata.codepointCount;
}

/// Is the string definite?
///
/// @param item a string
/// @return Is the string definite?
bool cborStringIsDefinite(CborItem item) {
  assert(cborIsaString(item));
  return item.metadata.stringMetadata.type ==
      CborDstMetadata.cborMetaDataDefinate;
}

/// Is the string indefinite?
///
/// @param item a string
/// @return Is the string indefinite?
bool cborStringIsIndefinite(CborItem item) {
  assert(cborIsaString(item));
  return item.metadata.stringMetadata.type ==
      CborDstMetadata.cborMetaDataIndefinate;
}

/// Get the handle to the underlying string
///
/// Definite items only. Modifying the data is allowed. In that case, the caller takes
/// responsibility for the effect on items this item might be a part of
///
/// @param item A definite string
/// @return The the underlying string. `NULL` if no data have been assigned yet.
String cborStringHandle(CborItem item) {
  assert(cborIsaString(item));
  return item.stringData;
}

/// Set the handle to the underlying string
///
/// @param item A definite string
/// @param data The string
void cborStringSetHandle(CborItem item, String data) {
  assert(cborIsaString(item));
  assert(cborStringIsDefinite(item));
  item.stringData = data;
  item.metadata.stringMetadata.length = data.length;
}

/// Appends a chunk to the string
///
/// Indefinite strings only.
///
/// @param item An indefinite string
/// @param item A definite string
/// @return true on success.
bool cborStringAddChunk(CborItem item, CborItem chunk) {
  assert(cborIsaString(item));
  assert(cborStringIsIndefinite(item));
  assert(cborStringIsDefinite(chunk));
  item.stringData += chunk.stringData;
  item.metadata.stringMetadata.length = item.stringData.length;
  return true;
}

/// Creates a new definite string
///
/// The handle is initialized to `NULL` and length to 0
///
/// @return **new** definite string.
CborItem cborNewDefiniteString() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeString;
  item.metadata.stringMetadata = new CborStringMetadata();
  item.metadata.stringMetadata.type = CborDstMetadata.cborMetaDataDefinate;
  item.metadata.stringMetadata.length = 0;
  return item;
}

/// Creates a new indefinite string
///
/// The handle is initialized to `NULL` and length to 0
///
/// @return **new** indefinite string.
CborItem cborNewIndefiniteString() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.type = CborType.cborTypeString;
  item.metadata.stringMetadata = new CborStringMetadata();
  item.metadata.stringMetadata.type = CborDstMetadata.cborMetaDataIndefinate;
  item.metadata.stringMetadata.length = 0;
  return item;
}


/// Creates a new string and initializes it
///
/// The `val` will be copied to a newly allocated block
///
/// @param val A UTF-8 string
/// @return A **new** string with content `handle`.
CborItem cborBuildString(String val) {
  CborItem item = cborNewDefiniteString();
  cborStringSetHandle(item, val);
  return item;
}


