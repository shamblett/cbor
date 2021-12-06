/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:typed_data/typed_buffers.dart' as typed;

import '../utils/info.dart';

class Header {
  Header(this.majorType, this.additionalInfo, this.dataBytes);

  final int majorType;
  final int additionalInfo;

  final Uint8List dataBytes;

  Info get info {
    if (additionalInfo < 24) {
      return Info.int(additionalInfo);
    } else {
      switch (additionalInfo) {
        case 24:
          return Info.int(dataBytes[0]);
        case 25:
          return Info.int(ByteData.view(dataBytes.buffer).getInt16(0));
        case 26:
          return Info.int(ByteData.view(dataBytes.buffer).getInt32(0));
        case 27:
          var i =
              BigInt.from(ByteData.view(dataBytes.buffer).getUint32(0)) << 32;
          i |= BigInt.from(ByteData.view(dataBytes.buffer).getUint32(4));
          return Info.bigInt(i);

        case 31:
          return Info.indefiniteLength();

        default:
          throw Error();
      }
    }
  }
}

class Reader {
  final typed.Uint8Buffer _bytes = typed.Uint8Buffer();
  int _read = 0;

  int get length => _bytes.length - _read;

  void add(List<int> input) => _bytes.addAll(input);

  Header? readHeader() {
    if (_bytes.length <= _read) {
      return null;
    }

    final x = _bytes[_read];
    final majorType = x >> 5;

    final additionalInfo = x & 0x1f;

    final Uint8List dataBytes;
    if (additionalInfo < 24 || additionalInfo == 31) {
      readUint8();
      dataBytes = Uint8List(0);
    } else {
      switch (additionalInfo) {
        case 24:
          if (_bytes.length < 2) {
            return null;
          }

          readUint8();
          dataBytes = readExactBytes(1)!;
          break;
        case 25:
          if (_bytes.length < 3) {
            return null;
          }

          readUint8();
          dataBytes = readExactBytes(2)!;
          break;
        case 26:
          if (_bytes.length < 5) {
            return null;
          }

          readUint8();
          dataBytes = readExactBytes(4)!;
          break;
        case 27:
          if (_bytes.length < 9) {
            return null;
          }

          readUint8();
          dataBytes = readExactBytes(8)!;
          break;
        default:
          throw FormatException('Invalid CBOR additional info');
      }
    }
    return Header(majorType, additionalInfo, dataBytes);
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
