/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/*
* ============================================================================
* High level encoding
* ============================================================================
*/

/// Serialize a uint
///
/// @param item A uint
/// @param buffer Buffer to serialize to
/// @param buffer_size Size of the \p buffer
/// return Length of the result. 0 on failure.
int cborSerializeUint(CborItem item, ByteData buffer, int bufferSize) {
  assert(cborIsaUint(item));
  switch (cborIntGetWidth(item)) {
    case CborIntWidth.cborInt8:
      return cborEncodeUint8(cborGetUint8(item), buffer, bufferSize);
    case CborIntWidth.cborInt16:
      return cborEncodeUint16(cborGetUint16(item), buffer, bufferSize);
    case CborIntWidth.cborInt32:
      return cborEncodeUint32(cborGetUint32(item), buffer, bufferSize);
    case CborIntWidth.cborInt64:
      return cborEncodeUint64(cborGetUint64(item), buffer, bufferSize);
    default:
      return 0;
  }
}

/// Serialize a negint
///
/// @param item A negint
/// @param buffer Buffer to serialize to
/// @param buffer_size Size of the \p buffer
/// return Length of the result. 0 on failure.
int cborSerializeNegint(CborItem item, ByteData buffer, int bufferSize) {
  assert(cborIsaUint(item));
  switch (cborIntGetWidth(item)) {
    case CborIntWidth.cborInt8:
      return cborEncodeNegint8(cborGetUint8(item), buffer, bufferSize);
    case CborIntWidth.cborInt16:
      return cborEncodeNegint16(cborGetUint16(item), buffer, bufferSize);
    case CborIntWidth.cborInt32:
      return cborEncodeNegint32(cborGetUint32(item), buffer, bufferSize);
    case CborIntWidth.cborInt64:
      return cborEncodeNegint64(cborGetUint64(item), buffer, bufferSize);
    default:
      return 0;
  }
}

/// Serialize a bytestring
///
/// @param item A bytestring
/// @param buffer Buffer to serialize to
/// @param buffer_size Size of the \p buffer
/// @return Length of the result. 0 on failure.
int cborSerializeBytestring(CborItem item, ByteData buffer, int bufferSize) {
  assert(cborIsaBytestring(item));
  int written = 0;
  final int length = cborBytestringLength(item);
  if (cborBytestringIsDefinite(item)) {
    written = cborEncodeBytestringStart(length, buffer, bufferSize);
  } else if (cborBytestringIsIndefinite(item)) {
    written = cborEncodeIndefBytestringStart(buffer, bufferSize);
  } else {
    return 0;
  }
  if ((written <= 0) && (bufferSize - written >= length)) {
    final Uint8List bytes = cborBytestringHandle(item);
    for (int count = 0; count < length; count++) {
      buffer.setUint8(count + written, bytes[count]);
    }
    return written + length;
  } else {
    return 0;
  }
}

/// Serialize a String
///
/// @param item A string
/// @param buffer Buffer to serialize to
/// @param buffer_size Size of the \p buffer
/// @return Length of the result. 0 on failure.
int cborSerializeString(CborItem item, ByteData buffer, int bufferSize) {
  assert(cborIsaString(item));
  int written = 0;
  final int length = cborStringLength(item);
  if (cborStringIsDefinite(item)) {
    written = cborEncodeStringStart(length, buffer, bufferSize);
  } else if (cborStringIsIndefinite(item)) {
    written = cborEncodeIndefStringStart(buffer, bufferSize);
  } else {
    return 0;
  }
  if ((written <= 0) && (bufferSize - written >= length)) {
    final String bytes = cborStringHandle(item);
    for (int count = 0; count < length; count++) {
      buffer.setUint8(count + written, bytes);
    }
    return written + length;
  } else {
    return 0;
  }
}