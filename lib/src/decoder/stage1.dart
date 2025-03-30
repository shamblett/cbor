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
import '../constants.dart';

import 'stage0.dart';

class Header {
  final int majorType;
  final int additionalInfo;

  final Uint8List dataBytes;

  Arg get arg {
    if (additionalInfo < CborAdditionalInfo.simpleValueHigh) {
      return Arg.int(additionalInfo);
    } else {
      switch (additionalInfo) {
        case CborAdditionalInfo.simpleValueHigh:
          return Arg.int(dataBytes.first);
        case CborAdditionalInfo.halfPrecisionFloat:
          return Arg.int(ByteData.view(dataBytes.buffer).getUint16(0));
        case CborAdditionalInfo.singlePrecisionFloat:
          return Arg.int(ByteData.view(dataBytes.buffer).getUint32(0));
        case CborAdditionalInfo.doublePrecisionFloat:
          var i =
              BigInt.from(ByteData.view(dataBytes.buffer).getUint32(0)) <<
              CborConstants.bitsPerWord;
          i |= BigInt.from(
            ByteData.view(
              dataBytes.buffer,
            ).getUint32(CborConstants.bytesPerWord),
          );
          return Arg.bigInt(i);

        case CborAdditionalInfo.breakStop:
          return Arg.indefiniteLength;

        default:
          throw Error();
      }
    }
  }

  Header(this.majorType, this.additionalInfo, this.dataBytes);
}

Header? _readHeader(Reader reader) {
  final x = reader.peekUint8();
  if (x == null) {
    return null;
  }

  final majorType = x >> CborConstants.additionalInfoByteRange;

  final additionalInfo = x & CborConstants.additionalInfoBitMask;

  final Uint8List dataBytes;
  if (additionalInfo < CborAdditionalInfo.simpleValueHigh ||
      additionalInfo == CborAdditionalInfo.breakStop) {
    reader.readUint8();
    dataBytes = Uint8List(0);
  } else {
    switch (additionalInfo) {
      case CborAdditionalInfo.simpleValueHigh:
        if (reader.length < CborConstants.two) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(CborConstants.one)!;
        break;
      case CborAdditionalInfo.halfPrecisionFloat:
        if (reader.length < CborConstants.three) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(CborConstants.two)!;
        break;
      case CborAdditionalInfo.singlePrecisionFloat:
        if (reader.length < CborConstants.five) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(CborConstants.four)!;
        break;
      case CborAdditionalInfo.doublePrecisionFloat:
        if (reader.length < CborConstants.nine) {
          return null;
        }

        reader.readUint8();
        dataBytes = reader.readExactBytes(CborConstants.byteLength)!;
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
  final Header header;
  final List<int> data;
  final int start;
  final int end;

  RawValue(
    this.header, {
    this.data = const [],
    required this.start,
    required this.end,
  });
}

class _Builder {
  final Header header;
  final Reader reader;
  final int offset;
  Uint8Buffer bytes = Uint8Buffer();

  _Builder(this.header, this.offset, this.reader);

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
  final Reader _reader = Reader();
  final Sink<RawValue> _sink;

  _Builder? _next;

  RawSink(this._sink);

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

      if (header.additionalInfo != CborAdditionalInfo.breakStop) {
        if (header.majorType == CborMajorType.byteString ||
            header.majorType == CborMajorType.textString) {
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
