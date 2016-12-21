/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

final String cborVersionStr = cborMajorVersion.toString() +
    "." +
    cborMinorVersion.toString() +
    "." +
    cborPatchVersion.toString();
final int cborHexVersion =
    ((cborMajorVersion << 16) | (cborMinorVersion << 8) | cborPatchVersion);

/*
* ============================================================================
* Type manipulation
* ============================================================================
*/

/// Get the type of the item
/// Standard item types as described by the RFC
///
/// @param item
/// @return The type
CborType cborTypeof(CborItem item) {
  return item.type;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_UINT?
bool cborIsaUint(CborItem item) {
  return item.type == CborType.cborTypeUint;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_NEGINT?
bool cborIsaNegint(CborItem item) {
  return item.type == CborType.cborTypeNegint;
}

///Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_BYTESTRING?
bool cborIsaBytestring(CborItem item) {
  return item.type == CborType.cborTypeBytestring;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_STRING?
bool cborIsaString(CborItem item) {
  return item.type == CborType.cborTypeString;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_ARRAY?
bool cborIsaArray(CborItem item) {
  return item.type == CborType.cborTypeArray;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_MAP?
bool cborIsaMap(CborItem item) {
  return item.type == CborType.cborTypeMap;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_TAG?
bool cborIsaTag(CborItem item) {
  return item.type == CborType.cborTypeTag;
}

/// Does the item have the appropriate major type?
/// @param item the item
/// @return Is the item an #CBOR_TYPE_FLOAT_CTRL?
bool cborIsaFloatCtrl(CborItem item) {
  return item.type == CborType.cborTypeFloatCtrl;
}

/* Practical types with respect to their semantics (but not tag values) */

/// Is the item an integer, either positive or negative?
/// @param item the item
/// @return  Is the item an integer, either positive or negative?
bool cborIsInt(CborItem item) {
  return cborIsaUint(item) || cborIsaNegint(item);
}

/// Is the item an a floating point number?
/// @param item the item
/// @return  Is the item a floating point number?
bool cborIsFloat(CborItem item) {
  return cborIsaFloatCtrl(item) && !cborFloatCtrlIsCtrl(item);
}

/// Is the item an a boolean?
/// @param item the item
/// @return  Is the item a boolean?
bool cborIsBool(CborItem item) {
  return cborIsaFloatCtrl(item) &&
      (cborCtrlValue(item) == cborCtrlToInt[ECborCtrl.cborCtrlFalse] ||
          cborCtrlValue(item) == cborCtrlToInt[ECborCtrl.cborCtrlTrue]);
}

/// Does this item represent `null`
/// @param item the item
/// @return  Is the item (CBOR logical) null?
bool cborIsNull(CborItem item) {
  return cborIsaFloatCtrl(item) &&
      cborCtrlValue(item) == cborCtrlToInt[ECborCtrl.cborCtrlNull];
}

/// Does this item represent `undefined`
/// @param item the item
/// @return Is the item (CBOR logical) undefined?
bool cborIsUndef(CborItem item) {
  return cborIsaFloatCtrl(item) &&
      cborCtrlValue(item) == cborCtrlToInt[ECborCtrl.cborCtrlUndef];
}
