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

/// Extracts the integer value
///
/// @param item positive or negative integer
/// @return the value
int cborGetInt(CborItem item) {
  assert(cborIsInt(item));
  switch (cborIntGetWidth(item)) {
    case CborIntWidth.cborInt8:
      return cborGetUint8(item);
    case CborIntWidth.cborInt16:
      return cborGetUint16(item);
    case CborIntWidth.cborInt32:
      return cborGetUint32(item);
    case CborIntWidth.cborInt64:
      return cborGetUint64(item);
  }
  return 0xDEADBEEF; /* Compiler complaints */
}

/// Assigns the integer value
///
/// @param item positive or negative integer item
/// @param value the value to assign. For negative integer, the logical value is `-value - 1`
void cborSetUint8(CborItem item, int value) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt8);
  item.intData = value;
}

/// Assigns the integer value
///
/// @param item positive or negative integer item
/// @param value the value to assign. For negative integer, the logical value is `-value - 1`
void cborSetUint16(CborItem item, int value) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt16);
  item.intData = value;
}

/// Assigns the integer value
///
/// @param item positive or negative integer item
/// @param value the value to assign. For negative integer, the logical value is `-value - 1`
void cborSetUint32(CborItem item, int value) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt32);
  item.intData = value;
}

/// Assigns the integer value
///
/// @param item positive or negative integer item
/// @param value the value to assign. For negative integer, the logical value is `-value - 1`
void cborSetUint64(CborItem item, int value) {
  assert(cborIsInt(item));
  assert(cborIntGetWidth(item) == CborIntWidth.cborInt64);
  item.intData = value;
}

/// Marks the integer item as a positive integer
///
/// The data value is not changed
///
/// @param item positive or negative integer item
void cborMarkUint(CborItem item) {
  assert(cborIsInt(item));
  item.type = CborType.cborTypeUint;
}

/// Marks the integer item as a negative integer
///
/// The data value is not changed
///
/// @param item positive or negative integer item
void cborMarkNegint(CborItem item) {
  assert(cborIsInt(item));
  item.type = CborType.cborTypeNegint;
}

/// Allocates new integer with 1B width
///
/// The width cannot be changed once allocated
///
/// @return **new** positive integer. The value is not initialized.
CborItem cborNewInt8() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.metadata.intMetadata.width = CborIntWidth.cborInt8;
  item.type = CborType.cborTypeUint;
  return item;
}

/// Allocates new integer with 2B width
///
/// The width cannot be changed once allocated
///
/// @return **new** positive integer. The value is not initialized.
CborItem cborNewInt16() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.metadata.intMetadata.width = CborIntWidth.cborInt16;
  item.type = CborType.cborTypeUint;
  return item;
}

/// Allocates new integer with 4B width
///
/// The width cannot be changed once allocated
///
/// @return **new** positive integer. The value is not initialized.
CborItem cborNewInt32() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.metadata.intMetadata.width = CborIntWidth.cborInt32;
  item.type = CborType.cborTypeUint;
  return item;
}

/// Allocates new integer with 8B width
///
/// The width cannot be changed once allocated
///
/// @return **new** positive integer. The value is not initialized.
CborItem cborNewInt64() {
  CborItem item = new CborItem();
  item.refcount = 1;
  item.metadata.intMetadata.width = CborIntWidth.cborInt64;
  item.type = CborType.cborTypeUint;
  return item;
}

/// Constructs a new positive integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildUint8(int value) {
  CborItem item = cborNewInt8();
  cborSetUint8(item, value);
  cborMarkUint(item);
  return item;
}

/// Constructs a new positive integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildUint16(int value) {
  CborItem item = cborNewInt16();
  cborSetUint8(item, value);
  cborMarkUint(item);
  return item;
}

/// Constructs a new positive integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildUint32(int value) {
  CborItem item = cborNewInt32();
  cborSetUint8(item, value);
  cborMarkUint(item);
  return item;
}

/// Constructs a new positive integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildUint64(int value) {
  CborItem item = cborNewInt64();
  cborSetUint8(item, value);
  cborMarkUint(item);
  return item;
}

/// Constructs a new negative integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildNegint8(int value) {
  CborItem item = cborNewInt8();
  cborSetUint8(item, value);
  cborMarkNegint(item);
  return item;
}

/// Constructs a new negative integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildNegint16(int value) {
  CborItem item = cborNewInt16();
  cborSetUint8(item, value);
  cborMarkNegint(item);
  return item;
}

/// Constructs a new negative integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildNegint32(int value) {
  CborItem item = cborNewInt32();
  cborSetUint8(item, value);
  cborMarkNegint(item);
  return item;
}

/// Constructs a new negative integer
///
/// @param value the value to use
/// @return **new** positive integer
CborItem cborBuildNegint64(int value) {
  CborItem item = cborNewInt64();
  cborSetUint8(item, value);
  cborMarkNegint(item);
  return item;
}
