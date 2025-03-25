/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/arg.dart';
import 'stage0.dart';

class Header {
  Header(this.majorType, this.additionalInfo, this.dataBytes);

  final int majorType;
  final int additionalInfo;

  final Uint8List dataBytes;

  Arg get arg {
    if (additionalInfo < 24) {
      return Arg.int(additionalInfo);
    } else {
      switch (additionalInfo) {
        case 24:
          return Arg.int(dataBytes[0]);
        case 25:
          return Arg.int(ByteData.view(dataBytes.buffer).getUint16(0));
        case 26:
          return Arg.int(ByteData.view(dataBytes.buffer).getUint32(0));
        case 27:
          var i =
              BigInt.from(ByteData.view(dataBytes.buffer).getUint32(0)) << 32;
          i |= BigInt.from(ByteData.view(dataBytes.buffer).getUint32(4));
          return Arg.bigInt(i);

        case 31:
          return Arg.indefiniteLength;

        default:
          throw Error();
      }
    }
  }
}

Header? _readHeader(Reader reader) {
  final x = reader.peekUint8();
  if (x == null) {
    return null;
  }

  final majorType = x >> 5;

  final additionalInfo = x & 0x1f;

  final Uint8List dataBytes;
  if (additionalInfo < 24 || additionalInfo == 31) {
    reader.readUint8();
    dataBytes = Uint8List(0);
  } else {
    switch (additionalInfo) {
      case 24:
        if (reader.length < 2) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(1)!;
        break;
      case 25:
        if (reader.length < 3) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(2)!;
        break;
      case 26:
        if (reader.length < 5) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(4)!;
        break;
      case 27:
        if (reader.length < 9) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(8)!;
        break;
      default:
        throw CborMalformedException(
          'Invalid CBOR additional info',
          reader.offset,
        );
    }
  }
  return Header(majorType, additionalInfo, dataBytes);
}

class RawValue {
  RawValue(
    this.header, {
    this.data = const [],
    required this.start,
    required this.end,
  });

  final Header header;
  final List<int> data;
  final int start;
  final int end;
}

class _Builder {
  _Builder(this.header, this.offset, this.reader);

  final Header header;
  final Reader reader;
  final int offset;
  Uint8Buffer bytes = Uint8Buffer();

  RawValue? poll() {
    if (bytes.length < header.arg.toInt()) {
      final read = reader.readBytes(header.arg.toInt() - bytes.length);
      bytes.addAll(read);
    }

    if (bytes.length < header.arg.toInt()) {
      return null;
    }

    return RawValue(header, data: bytes, start: offset, end: reader.offset);
  }
}

class RawSink extends ByteConversionSinkBase {
  RawSink(this._sink);

  final Reader _reader = Reader();
  final Sink<RawValue> _sink;

  _Builder? _next;

  @override
  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    _reader.add(chunk, start, end);

    while (true) {
      if (_next != null) {
        final value = _next?.poll();
        if (value == null) {
          break;
        }

        _next = null;
        _sink.add(value);
      }

      final offset = _reader.offset;

      final header = _readHeader(_reader);

      if (header == null) {
        break;
      }

      if (header.additionalInfo != 31) {
        if (header.majorType == 2 || header.majorType == 3) {
          _next = _Builder(header, offset, _reader);
          continue;
        }
      }

      _sink.add(RawValue(header, start: offset, end: _reader.offset));
    }

    if (isLast) {
      close();
    }
  }

  @override
  void add(List<int> chunk) {
    addSlice(chunk, 0, chunk.length, false);
  }

  @override
  void close() {
    _sink.close();
  }
}
