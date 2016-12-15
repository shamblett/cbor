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

/// Constructs a new float item
///
/// The width cannot be changed once the item is created
///
/// @return **new** 2B float
CborItem cborNewFloat2() {
  CborItem item = new CborItem();
  item.type = CborType.cborTypeFloatCtrl;
  item.floatData = double.NAN;
  item.refcount = 1;
  item.metadata.floatCtrlMetadata = new CborFloatCtrlMetadata();
  item.metadata.floatCtrlMetadata.width = CborFloatWidth.cborFloat16;
  return item;
}

/// Constructs a new float item
///
/// The width cannot be changed once the item is created
///
/// @return **new** 4B float
CborItem cborNewFloat4() {
  CborItem item = new CborItem();
  item.type = CborType.cborTypeFloatCtrl;
  item.floatData = double.NAN;
  item.refcount = 1;
  item.metadata.floatCtrlMetadata = new CborFloatCtrlMetadata();
  item.metadata.floatCtrlMetadata.width = CborFloatWidth.cborFloat32;
  return item;
}

/// Constructs a new float item
///
/// The width cannot be changed once the item is created
///
/// @return **new** 8B float
CborItem cborNewFloat8() {
  CborItem item = new CborItem();
  item.type = CborType.cborTypeFloatCtrl;
  item.floatData = double.NAN;
  item.refcount = 1;
  item.metadata.floatCtrlMetadata = new CborFloatCtrlMetadata();
  item.metadata.floatCtrlMetadata.width = CborFloatWidth.cborFloat32;
  return item;
}

/// Assign a control value
///
/// .. warning:: It is possible to produce an invalid CBOR value by assigning a invalid value using this mechanism. Please consult the standard before use.
///
/// @param item A ctrl item
/// @param value The simple value to assign. Please consult the standard for allowed values
void cborSetCtrl(CborItem item, int value) {
  assert(cborIsaFloatCtrl(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat0);
  item.metadata.floatCtrlMetadata.ctrl = value;
}

/// Constructs new null ctrl item
///
/// @return **new** null ctrl item
CborItem cborNewNull() {
  CborItem item = cborNewCtrl();
  cborSetCtrl(item, cborCtrlToInt[ECborCtrl.cborCtrlNull]);
  return item;
}

/// Constructs new undef ctrl item
///
/// @return **new** undef ctrl item
CborItem cborNewUndef() {
  CborItem item = cborNewCtrl();
  cborSetCtrl(item, cborCtrlToInt[ECborCtrl.cborCtrlUndef]);
  return item;
}

/// Constructs new boolean ctrl item
///
/// @param value The value to use
/// @return **new** boolean ctrl item
CborItem cborBuildBool(bool value) {
  return cborBuildCtrl(value
      ? cborCtrlToInt[ECborCtrl.cborCtrlTrue]
      : cborCtrlToInt[ECborCtrl.cborCtrlFalse]);
}

/// Assigns a float value
///
/// @param item A half precision float
/// @param value The value to assign
void cborSetFloat2(CborItem item, double value) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat16);
  item.floatData = value;
}

/// Assigns a float value
///
/// @param item A single precision float
/// @param value The value to assign
void cborSetFloat4(CborItem item, double value) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat32);
  item.floatData = value;
}

/// Assigns a float value
///
/// @param item A double precision float
/// @param value The value to assign
void cborSetFloat8(CborItem item, double value) {
  assert(cborIsFloat(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat64);
  item.floatData = value;
}

/// Reads the control value
///
/// @param item A ctrl item
/// @return the simple value
int cborCtrlValue(CborItem item) {
  assert(cborIsaFloatCtrl(item));
  assert(cborFloatGetWidth(item) == CborFloatWidth.cborFloat0);
  return item.CborFloatCtrlMetadata.ctrl;
}

/// Is this ctrl item a boolean?
///
/// @param item A ctrl item
/// @return Is this ctrl item a boolean?
bool cborCtrlIsBool(CborItem item) {
  assert(cborIsBool(item));
  return item.floatCtrlMetadata.ctrl == cborCtrlToInt[ECborCtrl.cborCtrlTrue];
}

/// Constructs a new float
///
/// @param value the value to use
/// @return **new** float
CborItem cborBuildFloat2(double value) {
  CborItem item = cborNewFloat2();
  cborSetFloat2(item, value);
  return item;
}

/// Constructs a new float
///
/// @param value the value to use
/// @return **new** float
CborItem cborBuildFloat4(double value) {
  CborItem item = cborNewFloat4();
  cborSetFloat4(item, value);
  return item;
}

/// Constructs a new float
///
/// @param value the value to use
/// @return **new** float
CborItem cborBuildFloat8(double value) {
  CborItem item = cborNewFloat8();
  cborSetFloat8(item, value);
  return item;
}
