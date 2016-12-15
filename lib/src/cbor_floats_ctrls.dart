/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* Float manipulation
* ============================================================================
*/

/// Get the float width
///
/// @param item A float or ctrl item
/// @return The width.
CborFloatWidth cborFloatGetWidth(CborItem item) {
  assert(cborIsaFloatCtrl(item));
  return item.metadata.floatCtrlMetadata.width;
}

/// Is this a ctrl value?
///
/// @param item A float or ctrl item
/// @return Is this a ctrl value?
bool cborFloatCtrlIsCtrl(CborItem item) {
  assert(cborIsaFloatCtrl(item));
  return cborFloatGetWidth(item) == CborFloatWidth.cborFloat0;
}

/// Get a half precision float
///
/// The item must have the corresponding width
///
/// @param A half precision float
/// @return half precision value
double cborFloatGetFloat2(CborItem item) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat16);
  return item.floatData;
}

/// Get a single precision float
///
/// The item must have the corresponding width
///
/// @param A single precision float
/// @return single precision value
double cborFloatGetFloat4(CborItem item) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat32);
  return item.floatData;
}

/// Get a double precision float
///
/// The item must have the corresponding width
///
/// @param A double precision float
/// @return double precision value
double cborFloatGetFloat8(CborItem item) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat64);
  return item.floatData;
}

/// Get the float value represented as double
///
/// Can be used regardless of the width.
///
/// @param Any float
/// @return double precision value or NAN
double cborFloatGetFloat(CborItem item) {
  assert(cborIsFloat(item));
  switch (cborFloatGetWidth(item)) {
    case CborFloatWidth.cborFloat0:
      return double.NAN;
    case CborFloatWidth.cborFloat16:
      return cborFloatGetFloat2(item);
    case CborFloatWidth.cborFloat32:
      return cborFloatGetFloat4(item);
    case CborFloatWidth.cborFloat64:
      return cborFloatGetFloat8(item);
  }
  return double.NAN;
}

/// Constructs a new ctrl item
///
/// The width cannot be changed once the item is created
///
/// @return **new** 1B ctrl
CborItem cborNewCtrl() {
  CborItem item = new CborItem();
  item.type = CborType.cborTypeFloatCtrl;
  item.floatData = double.NAN;
  item.refcount = 1;
  item.metadata.floatCtrlMetadata = new CborFloatCtrlMetadata();
  item.metadata.floatCtrlMetadata.width = CborFloatWidth.cborFloat0;
  item.metadata.floatCtrlMetadata.ctrl = cborCtrlToInt[ECborCtrl.cborCtrlNone];
  return item;
}
