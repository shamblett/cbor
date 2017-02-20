/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The encoder class implements the CBOR decoder functionality as defined in
/// RFC7049.

/// Numerical constants
final int two8 = pow(2, 8);
final int two16 = pow(2, 16);
final int two32 = pow(2, 32);

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
      // Value
      _out.putByte((type | value));
    } else if (value < two8) {
      // Uint8
      _out.putByte((type | 24));
      _out.putByte(value);
    } else if (value < two16) {
      // Uint16
      _out.putByte((type | 25));
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
      _out.putByte((type | 26));
      final typed.Uint32Buffer buff = new typed.Uint32Buffer(1);
      buff[0] = value;
      final Uint8List ulist = new Uint8List.view(buff.buffer);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll(ulist
          .toList()
          .reversed);
      _out.putBytes(data);
    } else {
      // Uint64
      _out.putByte((type | 27));
      final typed.Uint64Buffer buff = new typed.Uint64Buffer(1);
      buff[0] = value;
      final Uint8List ulist = new Uint8List.view(buff.buffer);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll(ulist
          .toList()
          .reversed);
      _out.putBytes(data);
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
