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

  void _writeTypeValue(int majorType, int value) {
    majorType <<= 5;
    if (value < 24) {
      _out.putByte((majorType | value));
    } else if (value < 256) {
      _out.putByte((majorType | 24));
      _out.putByte(value);
    } else if (value < 65536) {
      _out.putByte((majorType | 25));
      _out.putByte((value >> 8));
      _out.putByte(value);
    } else {
      _out.putByte((majorType | 26));
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
      _writeTypeValue(1, -(value + 1));
    } else {
      _writeTypeValue(0, value);
    }
  }

  void writeBytes(typed.Uint8Buffer data, int size) {
    _writeTypeValue(2, size);
    _out.putBytes(data, size);
  }

  void writeString(String str) {
    _writeTypeValue(3, str.length);
    typed.Uint8Buffer buff = new typed.Uint8Buffer(str.length);
    str.codeUnits.forEach((unit) {
      buff.add(unit);
    });
    _out.putBytes(buff, buff.length);
  }

  void writeBuff(typed.Uint8Buffer data, int size) {
    _writeTypeValue(3, size);
    _out.putBytes(data, size);
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
