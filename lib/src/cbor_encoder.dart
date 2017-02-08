/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

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
    type <<= 5;
    if (value < 24) {
      _out.putByte((type | value));
    } else if (value < 256) {
      _out.putByte((type | 24));
      _out.putByte(value);
    } else if (value < 65536) {
      _out.putByte((type | 25));
      _out.putByte((value >> 8));
      _out.putByte(value);
    } else {
      _out.putByte((type | 26));
      _out.putByte((value >> 24));
      _out.putByte((value >> 16));
      _out.putByte((value >> 8));
      _out.putByte(value);
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
      _writeTypeValue(1, -(value));
    } else {
      _writeTypeValue(0, value);
    }
  }

  void writeBytes(typed.Uint8Buffer data, int size) {
    _writeTypeValue(2, size);
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
    _writeTypeValue(7, special);
  }

  void writeNull() {
    _out.putByte(0xf6);
  }

  void writeUndefined() {
    _out.putByte(0xf7);
  }
}
