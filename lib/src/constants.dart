/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 27/03/2025
 * Copyright :  S.Hamblett
 */

// dart format width=123

/// Constants
class CborConstants {
  static const prettyPrintIndent = 2;
  static const hexRadix = 16;
  static const binRadix = 2;
  static const bytesPerWord = 4;
  static const bitsPerWord = 32;
  static const bitsPerDoubleWord = 64;
  static const additionalInfoByteRange = 5;
  static const additionalInfoBitMask = 0x1f;
  static const byteLength = 8;
  static const bigIntSlice = 33;
  static const maxYear = 9999;
  static const seconds = 60;
  static const milliseconds = 1000;
  static const jsonBitLength = 53;

  // Bitfields, padding, indents and ranges
  static const one = 1;
  static const two = 2;
  static const three = 3;
  static const four = 4;
  static const five = 5;
  static const six = 6;
  static const seven = 7;
  static const eight = 8;
  static const nine = 9;
  static const sixteen = 16;
}
