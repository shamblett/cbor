/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The encoder class implements the CBOR decoder functionality as defined in
/// RFC7049.

class Encoder {
  Output _out;

  Encoder(Output out) {
    this._out = out;
  }

  /// Clears the output buffer
  void clear() {
    _out.clear();
  }

  /// Booleans
  void writeBool(bool value) {
    if (value) {
      _out.putByte(0xf5);
    } else {
      _out.putByte(0xf4);
    }
  }

  /// Positive and negative integers
  void writeInt(int value) {
    if (value < 0) {
      _writeTypeValue(1, -(value + 1));
    } else {
      _writeTypeValue(0, value);
    }
  }

  /// Primitive byte writer
  void writeBytes(typed.Uint8Buffer data) {
    _writeTypeValue(2, data.length);
    _out.putBytes(data);
  }

  /// Primitive string writer
  void writeString(String str) {
    _writeTypeValue(3, str.length);
    _out.putBytes(strToByteString(str));
  }

  /// Bytestring primitive
  void writeBuff(typed.Uint8Buffer data, int size) {
    _writeTypeValue(3, size);
    _out.putBytes(data);
  }

  /// Array primitive
  void writeArray(int size) {
    _writeTypeValue(4, size);
  }

  /// Map primitive
  void writeMap(int size) {
    _writeTypeValue(5, size);
  }

  /// Tag primitive
  void writeTag(int tag) {
    _writeTypeValue(6, tag);
  }

  /// Special(major type 7) primitive
  void writeSpecial(int special) {
    int type = 7;
    type <<= majorTypeShift;
    _out.putByte(type | special);
  }

  /// Null writer
  void writeNull() {
    _out.putByte(0xf6);
  }

  /// Undefined writer
  void writeUndefined() {
    _out.putByte(0xf7);
  }

  /// Simple values, negative values, values over 255 or less
  /// than 0 will be encoded as an int.
  void writeSimple(int value) {
    if (!value.isNegative) {
      if ((value <= simpleLimitUpper) && (value >= simpleLimitLower)) {
        if (value <= 23) {
          writeSpecial(value);
        } else {
          writeSpecial(24);
          _out.putByte(value);
        }
      } else {
        writeInt(value);
      }
    } else {
      writeInt(value);
    }
  }

  /// Generalised float encoder, picks the smallest encoding
  /// it can. If you want a specific precision use the more
  /// specialised methods.
  /// Note this can lead to encodings you don't expect in corner cases,
  /// if you want a specific sized encodings don't use this.
  void writeFloat(double value) {
    if ((value <= halfLimitUpper) && (value >= halfLimitLower)) {
      writeHalf(value);
    } else if ((value <= singleLimitUpper) && (value >= singleLimitLower)) {
      writeSingle(value);
    } else {
      writeDouble(value);
    }
  }

  /// Half precision float
  void writeHalf(double value) {
    writeSpecial(ai25);
    // Special encodings
    if (value.isNaN) {
      _out.putByte(0x7e);
      _out.putByte(0x00);
    } else {
      final typed.Uint8Buffer valBuff = _singleToHalf(value);
      _out.putByte(valBuff[1]);
      _out.putByte(valBuff[0]);
    }
  }

  /// Single precision float
  void writeSingle(double value) {
    writeSpecial(ai26);
    // Special encodings
    if (value.isNaN) {
      _out.putByte(0x7f);
      _out.putByte(0xc0);
      _out.putByte(0x00);
      _out.putByte(0x00);
    } else {
      final typed.Float32Buffer fBuff = new typed.Float32Buffer(1);
      fBuff[0] = value;
      final ByteBuffer bBuff = fBuff.buffer;
      final Uint8List uList = bBuff.asUint8List();
      _out.putByte(uList[3]);
      _out.putByte(uList[2]);
      _out.putByte(uList[1]);
      _out.putByte(uList[0]);
    }
  }

  /// Double precision float
  void writeDouble(double value) {
    writeSpecial(ai27);
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
      final typed.Float64Buffer fBuff = new typed.Float64Buffer(1);
      fBuff[0] = value;
      final ByteBuffer bBuff = fBuff.buffer;
      final Uint8List uList = bBuff.asUint8List();
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
  /// Standard format as described in RFC339 et al
  void writeDateTime(String dt) {
    writeTag(0);
    writeString(dt);
  }

  /// Tag based epoch encoding. Format can be a positive
  /// or negative integer or a floating point number for
  /// which you can chose the encoding.
  void writeEpoch(num epoch, [encodeFloatAs floatType = encodeFloatAs.single]) {
    writeTag(1);
    if (epoch.runtimeType == int) {
      writeInt(epoch);
    } else {
      if (floatType == encodeFloatAs.half) {
        writeHalf(epoch);
      } else if (floatType == encodeFloatAs.single) {
        writeSingle(epoch);
      } else {
        writeDouble(epoch);
      }
    }
  }

  /// Tag based Base64 byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase64(typed.Uint8Buffer data) {
    writeTag(22);
    writeBytes(data);
  }

  /// Cbor data item encoder, refer to tyhe RFC for details.
  void writeCborDi(typed.Uint8Buffer data) {
    writeTag(24);
    writeBytes(data);
  }

  /// Tag based Base64 URL byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase64URL(typed.Uint8Buffer data) {
    writeTag(21);
    _out.putBytes(data);
  }

  /// Tag based Base16 byte string encoding. The encoder does not
  /// itself perform the base encoding as stated in RFC7049,
  /// it just indicates to the decoder that the following byte
  /// string maybe base encoded.
  void writeBase16(typed.Uint8Buffer data) {
    writeTag(23);
    writeBytes(data);
  }

  /// Tag based URI writer
  void writeURI(String uri) {
    writeTag(32);
    writeString(uri);
  }

  /// Lookup table based single to half precision conversion.
  /// Rounding is indeterminate.
  typed.Uint8Buffer _singleToHalf(double value) {
    final typed.Float32Buffer fBuff = new typed.Float32Buffer(1);
    fBuff[0] = value;
    final ByteBuffer bBuff = fBuff.buffer;
    final Uint8List uList = bBuff.asUint8List();
    final int intVal =
    uList[0] | uList[1] << 8 | uList[2] << 16 | uList[3] << 24;
    final int index = intVal >> 23;
    final int masked = intVal & 0x7FFFFF;
    final int hBits = baseTable[index] + ((masked) >> shiftTable[index]);
    final typed.Uint16Buffer hBuff = new typed.Uint16Buffer(1);
    hBuff[0] = hBits;
    final ByteBuffer lBuff = hBuff.buffer;
    final Uint8List hList = lBuff.asUint8List();
    final typed.Uint8Buffer valBuff = new typed.Uint8Buffer();
    valBuff.addAll(hList);
    return valBuff;
  }

  /// Encoding helper for type encoding
  void _writeTypeValue(int majorType, int value) {
    int type = majorType;
    type <<= majorTypeShift;
    if (value < ai24) {
      // Value
      _out.putByte((type | value));
    } else if (value < two8) {
      // Uint8
      _out.putByte((type | ai24));
      _out.putByte(value);
    } else if (value < two16) {
      // Uint16
      _out.putByte((type | ai25));
      final typed.Uint16Buffer buff = new typed.Uint16Buffer(1);
      buff[0] = value;
      final Uint8List ulist = new Uint8List.view(buff.buffer);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll(ulist
          .toList()
          .reversed);
      _out.putBytes(data);
    } else if (value < two32) {
      // Uint32
      _out.putByte((type | ai26));
      final typed.Uint32Buffer buff = new typed.Uint32Buffer(1);
      buff[0] = value;
      final Uint8List ulist = new Uint8List.view(buff.buffer);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll(ulist
          .toList()
          .reversed);
      _out.putBytes(data);
    } else if (value < two64) {
      // Uint64
      _out.putByte((type | ai27));
      final typed.Uint64Buffer buff = new typed.Uint64Buffer(1);
      buff[0] = value;
      final Uint8List ulist = new Uint8List.view(buff.buffer);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll(ulist
          .toList()
          .reversed);
      _out.putBytes(data);
    } else {
      // Bignum - not supported, use tags
      print("Bignums not supported");
    }
  }

  ///String to byte string helper.
  typed.Uint8Buffer strToByteString(String str) {
    final typed.Uint8Buffer buff = new typed.Uint8Buffer();
    str.codeUnits.forEach((int unit) {
      buff.add(unit);
    });
    return buff;
  }
}
