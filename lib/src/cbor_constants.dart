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

/// Additional information constants
const int ai20 = 20;
const int ai21 = 21;
const int ai22 = 22;
const int ai23 = 23;
const int ai24 = 24;
const int ai25 = 25;
const int ai26 = 26;
const int ai27 = 27;
const int aiBreak = 31;
