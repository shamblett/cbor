/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Specifies the Major type of ::cbor_item_t
enum cbor_type {
  cborTypeUint, // 0 - positive integers
  cborTypeNegint, // 1 - negative integers
  cborTypeBytestring, // 2 - byte strings
  cborTypeString, // 3 - strings
  cborTypeArray, // 4 - arrays
  cborTypeMap, // 5 - maps
  cborTypeTag, // 6 - tags
  cborTypeFloatCtrl // 7 - decimals and special values (true, false, nil, ...)
}

/// Possible decoding errors
enum cbor_error_code {
  cborErrNone,
  cborErrNotEnoughData,
  cborErrNodata,
  cborErrMalformated,
  cborErrSyntaxError // Stack parsing algorithm failed
}

// Possible widths of #CBOR_TYPE_UINT items
enum cbor_int_width { cborInt8, cborInt16, cborInt32, cborInt64 }

/// Possible widths of #CBOR_TYPE_FLOAT_CTRL items
enum cbor_float_width {
  cborFloat0, // Internal use - ctrl and special values
  cborFloat16, // Half float
  cborFloat32, // Single float
  cborFloat64 // Double
}

/// Metadata for dynamically sized types
enum cbor_dst_metadata { cborMetaDataDefinate, cborMetaDataIndefinate }

/// Semantic mapping for CTRL simple values
enum _cbor_ctrl {
  cborCtrlNone,
  cborCtrlFalse,
  cborCtrlTrue,
  cborCtrlNull,
  cborCtrlUndef
}

const Map<List<int>,List<_cbor_ctrl>> cbor_ctrl = {
  0: _cbor_ctrl.cborCtrlNone.index,
  20: _cbor_ctrl.cborCtrlFalse.index,
  21: _cbor_ctrl.cborCtrlTrue.index,
  22: _cbor_ctrl.cborCtrlNull.index,
  23: _cbor_ctrl.cborCtrlUndef.index
};

/// Integers specific metadata
class cbor_int_metadata {
  cbor_int_width width;
}


