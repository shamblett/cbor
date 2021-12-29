/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:typed_data/typed_buffers.dart' as typed;

class Reader {
  final typed.Uint8Buffer _bytes = typed.Uint8Buffer();
  int _read = 0;
  int _offset = 0;

  int get offset => _offset;
  int get length => _bytes.length - _read;

  void add(List<int> input, [int start = 0, int? end]) =>
      _bytes.addAll(input, start, end);

  int? peekUint8() {
    if (_read == _bytes.length) {
      return null;
    }

    return _bytes[_read];
  }

  int? readUint8() {
    return readExactBytes(1)?[0];
  }

  int? readUint16(int offset) {
    final bytes = readExactBytes(2);
    if (bytes != null) {
      return ByteData.view(bytes.buffer).getUint16(0);
    }
  }

  int? readUint32(int offset) {
    final bytes = readExactBytes(4);
    if (bytes != null) {
      return ByteData.view(bytes.buffer).getUint32(0);
    }
  }

  BigInt? readUint64(int offset) {
    final bytes = readExactBytes(4);
    if (bytes != null) {
      var i = BigInt.from(ByteData.view(bytes.buffer).getUint32(0)) << 4;
      i |= BigInt.from(ByteData.view(bytes.buffer).getUint32(4));
      return i;
    }
  }

  Uint8List? readExactBytes(int c) {
    if (_read + c <= _bytes.length) {
      final bytes = _bytes.buffer.asUint8List().sublist(_read, c + _read);
      _read += c;
      _offset += c;

      if (length < _bytes.length ~/ 4) {
        _bytes.removeRange(0, _read);
        _read = 0;
      }

      return bytes;
    }
  }

  Uint8List readBytes(int maximum) {
    return readExactBytes(min(maximum, length))!;
  }
}
