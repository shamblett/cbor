/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Builder hook function type. The bool parameter
/// is set to true if the encoded entity can be used as a
/// map key.
typedef BuilderHook = void Function(bool, dynamic);

/// Float encoding directives
enum encodeFloatAs { half, single, double }

/// The encoder class implements the CBOR encoder functionality as defined in
/// RFC7049. This class is intended for single CBOR entity encoding, indefinite
/// sequences and simple lists and maps
///
/// For specific more complex encoding such as for specialised lists and maps that
/// contain raw byte sequences, tag values etc. use the builder classes.
class Encoder {
  /// Construction
  Encoder(Output out) {
    _out = out;
    _builderHook = nullBuilderHook;
  }

  /// The output buffer
  @protected
  Output _out;

  @protected
  BuilderHook _builderHook;

  /// Indefinite sequence indicator, incremented on start
  /// decremented on stop.
  int _indefSequenceCount = 0;

  /// Clears the output buffer.
  void clear() {
    _out.clear();
  }

  /// Booleans.
  void writeBool(bool value) {
    _writeBool(value);
    _builderHookImpl(false);
  }

  void _writeBool(bool value) {
    if (value) {
      _out.putByte(0xf5);
    } else {
      _out.putByte(0xf4);
    }
  }

  /// Positive and negative integers.
  /// If the value is too large to be encoded as an integer
  /// it is automatically converted to and encoded as a big num
  void writeInt(int value) {
    _writeInt(value);
    _builderHookImpl(true, value);
  }

  void _writeInt(int value) {
    if (value < 0) {
      _writeTypeValue(1, -(value + 1));
    } else {
      _writeTypeValue(0, value);
    }
  }

  void writeBignum(BigInt value) {
    _writeBignum(value);
    _builderHookImpl(false, value);
  }

  void _writeBignum(BigInt value) {
    if (value.isNegative) {
      _writeTag(tagNegativeBignum);
    } else {
      _writeTag(tagPositiveBignum);
    }
    var str = value.toRadixString(16);
    if (str.length.isOdd) {
      str = '0$str';
    }
    final bytes = hexToBytes(str);
    final data = typed.Uint8Buffer();
    data.addAll(bytes.asUint8List());
    _writeTypeValue(majorTypeBytes, data.length);
    _out.putBytes(data);
  }

  /// Primitive byte writer.
  void writeBytes(typed.Uint8Buffer data) {
    _writeBytes(data);
    _builderHookImpl(false);
  }

  void _writeBytes(typed.Uint8Buffer data) {
    _writeTypeValue(majorTypeBytes, data.length);
    _out.putBytes(data);
  }

  /// Add the output of a builder to the encoding stream.
  void addBuilderOutput(typed.Uint8Buffer buffer) {
    _writeRawBuffer(buffer);
    _builderHookImpl(false);
  }

  /// Raw byte buffer writer.
  /// No encoding is added to the buffer, it goes into the
  /// output stream as is.
  void writeRawBuffer(typed.Uint8Buffer buff) {
    _writeRawBuffer(buff);
    _builderHookImpl(false);
  }

  void _writeRawBuffer(typed.Uint8Buffer buff) {
    _out.putBytes(buff);
  }

  /// Primitive string writer.
  void writeString(String str, [bool indefinite = false]) {
    _writeString(str, indefinite);
    _builderHookImpl(true, str);
  }

  void _writeString(String str, [bool indefinite = false]) {
    final buff = strToByteString(str);
    if (indefinite) {
      startIndefinite(majorTypeString);
    }
    _writeTypeValue(majorTypeString, buff.length);
    _out.putBytes(buff);
  }

  /// Byte string primitive.
  void writeBuff(typed.Uint8Buffer data, [bool indefinite = false]) {
    _writeBuff(data, indefinite);
    _builderHookImpl(false);
  }

  void _writeBuff(typed.Uint8Buffer data, [bool indefinite = false]) {
    if (indefinite) {
      startIndefinite(majorTypeBytes);
    }
    _writeTypeValue(majorTypeBytes, data.length);
    _out.putBytes(data);
  }

  /// Array primitive.
  /// Valid elements are string, integer, bool, float(any size), array
  /// or map. Returns true if the encoding has been successful.
  /// If you supply a length this will be used and not calculated from the
  /// array size, unless you are encoding certain indefinite sequences you
  /// do not need to do this.
  bool writeArray(List<dynamic> value, [bool indefinite = false, int length]) {
    // Mark the output buffer, if we cannot encode
    // the whole array structure rewind so as to perform
    // no encoding.
    var res = true;
    _out.mark();
    final ok = _writeArrayImpl(value, indefinite, length);
    if (!ok) {
      _out.resetToMark();
      res = false;
    }
    _builderHookImpl(false);
    return res;
  }

  /// Map primitive.
  /// Valid map keys are integer and string. RFC7049
  /// recommends keys be of a single type, we are more generous
  /// here.
  /// Valid map values are integer, string, bool, float(any size), array
  /// map or buffer. Returns true if the encoding has been successful.
  bool writeMap(Map<dynamic, dynamic> value,
      [bool indefinite = false, int length]) {
    // Mark the output buffer, if we cannot encode
    // the whole map structure rewind so as to perform
    // no encoding.
    var res = true;
    _out.mark();
    final ok = _writeMapImpl(value, indefinite, length);
    if (!ok) {
      _out.resetToMark();
      res = false;
    }
    _builderHookImpl(false);
    return res;
  }

  /// Tag primitive.
  void writeTag(int tag) {
    _writeTag(tag);
  }

  void _writeTag(int tag) {
    _writeTypeValue(majorTypeTag, tag);
  }

  /// Special(major type 7) primitive.
  void writeSpecial(int special) {
    _writeSpecial(special);
  }

  void _writeSpecial(int special) {
    var type = majorTypeSpecial;
    type <<= majorTypeShift;
    _out.putByte(type | special);
  }

  /// Null writer.
  void writeNull() {
    _writeNull();
    _builderHookImpl(false);
  }

  void _writeNull() {
    _out.putByte(0xf6);
  }

  /// Undefined writer.
  void writeUndefined() {
    _out.putByte(0xf7);
    _builderHookImpl(false);
  }

  /// Indefinite item break primitive.
  void writeBreak() {
    _writeSpecial(aiBreak);
    _indefSequenceCount--;
    _builderHookImpl(false);
  }

  /// Indefinite item start.
  void startIndefinite(int majorType) {
    _out.putByte((majorType << 5) + aiBreak);
    _indefSequenceCount++;
  }

  /// Simple values, negative values, values over 255 or less
  /// than 0 will be encoded as an int.
  void writeSimple(int value) {
    if (!value.isNegative) {
      if ((value <= simpleLimitUpper) && (value >= simpleLimitLower)) {
        if (value <= ai23) {
          _writeSpecial(value);
        } else {
          _writeSpecial(ai24);
          _out.putByte(value);
        }
      } else {
        _writeInt(value);
      }
    } else {
      _writeInt(value);
    }
    _builderHookImpl(true);
  }

  /// Generalised float encoder, picks the smallest encoding
  /// it can. If you want a specific precision use the more
  /// specialised methods.
  /// Note this can lead to encodings you may not expect in corner cases,
  /// if you want specific sized encodings don't use this.
  void writeFloat(double value) {
    _writeFloat(value);
    _builderHookImpl(false);
  }

  void _writeFloat(double value) {
    if (canBeAHalf(value)) {
      _writeHalf(value);
    } else if (canBeASingle(value)) {
      _writeSingle(value);
    } else {
      _writeDouble(value);
    }
  }

  /// Half precision float.
  void writeHalf(double value) {
    _writeHalf(value);
    _builderHookImpl(false);
  }

  void _writeHalf(double value) {
    _writeSpecial(ai25);
    // Special encodings
    if (value.isNaN) {
      _out.putByte(0x7e);
      _out.putByte(0x00);
    } else {
      final valBuff = _singleToHalf(value);
      _out.putByte(valBuff[1]);
      _out.putByte(valBuff[0]);
    }
  }

  /// Single precision float.
  void writeSingle(double value) {
    _writeSingle(value);
    _builderHookImpl(false);
  }

  void _writeSingle(double value) {
    _writeSpecial(ai26);
    // Special encodings
    if (value.isNaN) {
      _out.putByte(0x7f);
      _out.putByte(0xc0);
      _out.putByte(0x00);
      _out.putByte(0x00);
    } else {
      final fBuff = typed.Float32Buffer(1);
      fBuff[0] = value;
      final bBuff = fBuff.buffer;
      final uList = bBuff.asUint8List();
      _out.putByte(uList[3]);
      _out.putByte(uList[2]);
      _out.putByte(uList[1]);
      _out.putByte(uList[0]);
    }
  }

  /// Double precision float.
  void writeDouble(double value) {
    _writeDouble(value);
    _builderHookImpl(false);
  }

  void _writeDouble(double value) {
    _writeSpecial(ai27);
    // Special encodings
    if (value.isNaN) {
      _out.putByte(0x7f);
      _out.putByte(0xf8);
      _out.putByte(0x00);
      _out.putByte(0x00);
      _out.putByte(0x00);
      _out.putByte(0x00);
      _out.putByte(0x00);
      _out.putByte(0x00);
    } else {
      final fBuff = typed.Float64Buffer(1);
      fBuff[0] = value;
      final bBuff = fBuff.buffer;
      final uList = bBuff.asUint8List();
      _out.putByte(uList[7]);
      _out.putByte(uList[6]);
      _out.putByte(uList[5]);
      _out.putByte(uList[4]);
      _out.putByte(uList[3]);
      _out.putByte(uList[2]);
      _out.putByte(uList[1]);
      _out.putByte(uList[0]);
    }
  }

  /// Tag based Date/Time encoding.
  /// Standard format as described in RFC339 et al.
  void writeDateTime(String dt) {
    _writeTag(tagDateTimeStandard);
    _writeString(dt);
    _builderHookImpl(false);
  }

  /// Tag based epoch encoding. Format can be a positive
  /// or negative integer or a floating point number for
  /// which you can chose the encoding.
  void writeEpoch(num epoch, [encodeFloatAs floatType = encodeFloatAs.single]) {
    _writeTag(tagDateTimeEpoch);
    if (epoch.runtimeType == int) {
      _writeInt(epoch);
    } else {
      if (floatType == encodeFloatAs.half) {
        _writeHalf(epoch);
      } else if (floatType == encodeFloatAs.single) {
        _writeSingle(epoch);
      } else {
        _writeDouble(epoch);
      }
    }
    _builderHookImpl(false);
  }

  /// Tag based Base64 byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase64(typed.Uint8Buffer data) {
    _writeTag(tagExpectedBase64);
    _writeBytes(data);
    _builderHookImpl(false);
  }

  /// Cbor data item encoder, refer to the RFC for details.
  void writeCborDi(typed.Uint8Buffer data) {
    _writeTag(tagEncodedCborDataItem);
    _writeBytes(data);
    _builderHookImpl(false);
  }

  /// Tag based Base64 URL byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase64URL(typed.Uint8Buffer data) {
    _writeTag(tagExpectedBase64Url);
    _writeBytes(data);
    _builderHookImpl(false);
  }

  /// Tag based Base16 byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase16(typed.Uint8Buffer data) {
    _writeTag(tagExpectedBase16);
    _writeBytes(data);
    _builderHookImpl(false);
  }

  /// Tag based URI writer
  void writeURI(String uri) {
    _writeTag(tagUri);
    _writeString(uri);
    _builderHookImpl(false);
  }

  /// Tag based Regex writer.
  /// Note this method does not attempt to validate the
  /// RegEx expression supplied.
  void writeRegEx(String regex) {
    _writeTag(tagRegularExpression);
    _writeString(regex);
    _builderHookImpl(false);
  }

  /// Tag based MIME message writer.
  /// Note this method does not attempt to validate the
  /// MIME message supplied.
  void writeMimeMessage(String message) {
    _writeTag(tagMimeMessage);
    _writeString(message);
    _builderHookImpl(false);
  }

  /// Helper functions

  /// Lookup table based single to half precision conversion.
  /// Rounding is indeterminate.
  typed.Uint8Buffer _singleToHalf(double value) {
    final hBits = getHalfPrecisionInt(value);
    final hBuff = typed.Uint16Buffer(1);
    hBuff[0] = hBits;
    final lBuff = hBuff.buffer;
    final hList = lBuff.asUint8List();
    final valBuff = typed.Uint8Buffer();
    valBuff.addAll(hList);
    return valBuff;
  }

  /// Encoding helper for type encoding.
  void _writeTypeValue(int majorType, int value) {
    var type = majorType;
    type <<= majorTypeShift;
    if (value < ai24) {
      // Value
      _out.putByte(type | value);
    } else if (value < two8) {
      // Uint8
      _out.putByte(type | ai24);
      _out.putByte(value);
    } else if (value < two16) {
      // Uint16
      _out.putByte(type | ai25);
      final buff = typed.Uint16Buffer(1);
      buff[0] = value;
      final ulist = Uint8List.view(buff.buffer);
      final data = typed.Uint8Buffer();
      data.addAll(ulist.toList().reversed);
      _out.putBytes(data);
    } else if (value < two32) {
      // Uint32
      _out.putByte(type | ai26);
      final buff = typed.Uint32Buffer(1);
      buff[0] = value;
      final ulist = Uint8List.view(buff.buffer);
      final data = typed.Uint8Buffer();
      data.addAll(ulist.toList().reversed);
      _out.putBytes(data);
    } else if (value < two64) {
      // Uint64
      _out.putByte(type | ai27);
      final buff = typed.Uint64Buffer(1);
      buff[0] = value;
      final ulist = Uint8List.view(buff.buffer);
      final data = typed.Uint8Buffer();
      data.addAll(ulist.toList().reversed);
      _out.putBytes(data);
    } else {
      // Bignum - encoded as a tag value
      _writeBignum(BigInt.from(value));
    }
  }

  /// String to byte string helper.
  typed.Uint8Buffer strToByteString(String str) {
    final buff = typed.Uint8Buffer();
    const utf = convertor.Utf8Encoder();
    final List<int> codes = utf.convert(str);
    buff.addAll(codes);
    return buff;
  }

  /// Array write implementation method.
  /// If the array cannot be fully encoded no encoding occurs,
  /// ie false is returned.
  @Deprecated('This will be removed - use a List Builder')
  bool writeArrayImpl(List<dynamic> value,
          [bool indefinite = false, int length]) =>
      _writeArrayImpl(value, indefinite, length);

  bool _writeArrayImpl(List<dynamic> value,
      [bool indefinite = false, int length]) {
    // Check for empty
    if (value.isEmpty) {
      if (!indefinite) {
        _writeTypeValue(majorTypeArray, 0);
      } else {
        startIndefinite(majorTypeArray);
      }
      return true;
    }

    // Build the encoded array.
    if (!indefinite) {
      if (length != null) {
        _writeTypeValue(majorTypeArray, length);
      } else {
        _writeTypeValue(majorTypeArray, value.length);
      }
    } else {
      startIndefinite(majorTypeArray);
    }

    var ok = true;
    for (final dynamic element in value) {
      var valType = element.runtimeType.toString();
      if (valType.contains('List')) {
        valType = 'List';
      }
      if (valType.contains('Map')) {
        valType = 'Map';
      }
      switch (valType) {
        case 'int':
          _writeInt(element);
          break;
        case 'String':
          _writeString(element);
          break;
        case 'double':
          _writeFloat(element);
          break;
        case 'List':
          if (!indefinite) {
            final res = _writeArrayImpl(element, indefinite);
            if (!res) {
              // Fail the whole encoding
              ok = false;
            }
          } else {
            element.forEach(_out.putByte);
          }
          break;
        case 'Map':
          if (!indefinite) {
            final res = _writeMapImpl(element, indefinite);
            if (!res) {
              // Fail the whole encoding
              ok = false;
            }
          } else {
            element.forEach(_out.putByte);
          }
          break;
        case 'bool':
          _writeBool(element);
          break;
        case 'Null':
          _writeNull();
          break;
        case 'Uint8Buffer':
          _writeRawBuffer(element);
          break;
        default:
          print('writeArrayImpl::RT is ${element.runtimeType.toString()}');
          ok = false;
      }
    }
    return ok;
  }

  /// Map write implementation method.
  /// If the map cannot be fully encoded no encoding occurs,
  /// ie false is returned.
  @Deprecated('This will be removed - use a Map Builder')
  bool writeMapImpl(Map<dynamic, dynamic> value,
          [bool indefinite = false, int length]) =>
      _writeMapImpl(value, indefinite, length);

  bool _writeMapImpl(Map<dynamic, dynamic> value,
      [bool indefinite = false, int length]) {
    // Check for empty
    if (value.isEmpty) {
      if (!indefinite) {
        _writeTypeValue(majorTypeMap, 0);
      }
      return true;
    }

    // Check the keys are integers or strings.
    final dynamic keys = value.keys;
    var keysValid = true;
    for (final dynamic element in keys) {
      if (!(element.runtimeType.toString() == 'int') &&
          !(element.runtimeType.toString() == 'String')) {
        keysValid = false;
        break;
      }
    }
    if (!keysValid) {
      return false;
    }
    // Build the encoded map.
    if (!indefinite) {
      if (_indefSequenceCount == 0) {
        if (length != null) {
          _writeTypeValue(majorTypeMap, length);
        } else {
          _writeTypeValue(majorTypeMap, value.length);
        }
      }
    } else {
      startIndefinite(majorTypeMap);
    }

    var ok = true;
    value.forEach((key, val) {
      // Encode the key, can now only be ints or strings.
      if (key.runtimeType.toString() == 'int') {
        _writeInt(key);
      } else {
        _writeString(key);
      }
      // Encode the value
      var valType = val.runtimeType.toString();
      if (valType.contains('List')) {
        valType = 'List';
      }
      if (valType.contains('Map')) {
        valType = 'Map';
      }
      switch (valType) {
        case 'int':
          _writeInt(val);
          break;
        case 'String':
          _writeString(val);
          break;
        case 'double':
          _writeFloat(val);
          break;
        case 'List':
          if (!indefinite) {
            final res = _writeArrayImpl(val, indefinite);
            if (!res) {
              // Fail the whole encoding
              ok = false;
            }
          } else {
            val.forEach(_out.putByte);
          }
          break;
        case 'Map':
          if (!indefinite) {
            final res = _writeMapImpl(val, indefinite);
            if (!res) {
              // Fail the whole encoding
              ok = false;
            }
          } else {
            val.forEach(_out.putByte);
          }
          break;
        case 'bool':
          _writeBool(val);
          break;
        case 'Null':
          _writeNull();
          break;
        case 'Uint8Buffer':
          _writeRawBuffer(val);
          break;
        default:
          print('writeMapImpl::RT is ${val.runtimeType.toString()}');
          ok = false;
      }
    });
    return ok;
  }

  void _builderHookImpl(bool validAsMapKey, [dynamic keyValue]) {
    if (_indefSequenceCount == 0) {
      _builderHook(validAsMapKey, keyValue);
    }
  }

  // Builder hook dummy
  void nullBuilderHook(bool validAsMapKey, dynamic keyValue) {}
}
