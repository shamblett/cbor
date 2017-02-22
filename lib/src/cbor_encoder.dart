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

  void clear() {
    _out.clear();
  }

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

  void writeBool(bool value) {
    if (value) {
      _out.putByte(0xf5);
    } else {
      _out.putByte(0xf4);
    }
  }

  void writeInt(int value) {
    if (value < 0) {
      _writeTypeValue(1, -(value + 1));
    } else {
      _writeTypeValue(0, value);
    }
  }

  void writeBytes(typed.Uint8Buffer data) {
    _writeTypeValue(2, data.length);
    _out.putBytes(data);
  }

  void writeString(String str) {
    _writeTypeValue(3, str.length);
    final typed.Uint8Buffer buff = new typed.Uint8Buffer();
    str.codeUnits.forEach((int unit) {
      buff.add(unit);
    });
    _out.putBytes(buff);
  }

  void writeBuff(typed.Uint8Buffer data, int size) {
    _writeTypeValue(3, size);
    _out.putBytes(data);
  }

  void writeArray(int size) {
    _writeTypeValue(4, size);
  }

  void writeMap(int size) {
    _writeTypeValue(5, size);
  }

  void writeTag(int tag) {
    _writeTypeValue(6, tag);
  }

  void writeSpecial(int special) {
    int type = 7;
    type <<= majorTypeShift;
    _out.putByte(type | special);
  }

  void writeNull() {
    _out.putByte(0xf6);
  }

  void writeUndefined() {
    _out.putByte(0xf7);
  }

  /// Simple values, values over 255 or less
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
}
