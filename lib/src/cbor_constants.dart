/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// CBOR decoding constants
const int majorTypeShift = 5;
const int minorTypeMask = 31;

/// Major type constants
const int majorTypePint = 0;
const int majorTypeNint = 1;
const int majorTypeBytes = 2;
const int majorTypeString = 3;
const int majorTypeArray = 4;
const int majorTypeMap = 5;
const int majorTypeTag = 6;
const int majorTypeSpecial = 7;
