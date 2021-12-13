/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';
import 'package:ieee754/ieee754.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/info.dart';
import '../utils/utils.dart';
import '../value/value.dart';
import 'reader.dart';

class _IncompatibleTagException extends FormatException {
  _IncompatibleTagException(int offset)
      : super('Incompatible tags', null, offset);
}

class BuilderReader {
  BuilderReader(this.strict);

  final bool strict;
  final Reader _reader = Reader();
  List<int> _tags = [];

  Utf8Codec get utf8 {
    if (strict) {
      return const Utf8Codec(allowMalformed: false);
    } else {
      return const Utf8Codec(allowMalformed: true);
    }
  }

  int get remaniningBytes => _reader.length;

  void add(List<int> input) {
    _reader.add(input);
  }

  List<int> _clearTags() {
    final tags = _tags;
    _tags = [];
    return tags;
  }

  Builder? read([bool allowBreak = false]) {
    while (true) {
      final offset = _reader.offset;
      final header = _reader.readHeader();

      if (header == null) {
        return null;
      }

      switch (header.majorType) {
        case 0: // uint
          return _ValueBuilder(_createInt(offset, header.info, _clearTags()));
        case 1: // negative
          return _ValueBuilder(_createInt(offset, ~header.info, _clearTags()));

        case 2: // bytes
          if (header.info.isIndefiniteLength) {
            return _IndefiniteBytesBuilder(offset, this, _clearTags());
          } else {
            return _BytesBuilder(
                offset, this, _clearTags(), header.info.toInt());
          }

        case 3: // string
          if (header.info.isIndefiniteLength) {
            return _IndefiniteStringBuilder(offset, this, _clearTags());
          } else {
            return _StringBuilder(
                offset, this, _clearTags(), header.info.toInt());
          }

        case 4: // array
          if (header.info.isIndefiniteLength) {
            return _IndefiniteListBuilder(offset, this, _clearTags());
          } else {
            return _ListBuilder(
                offset, this, header.info.toInt(), _clearTags());
          }

        case 5: // map
          if (header.info.isIndefiniteLength) {
            return _IndefiniteMapBuilder(offset, this, _clearTags());
          } else {
            return _MapBuilder(offset, this, header.info.toInt(), _clearTags());
          }

        case 6: // tags
          _tags.add(header.info.toInt());
          break;

        case 7:
          switch (header.additionalInfo) {
            case 20:
              return _ValueBuilder(_createBool(offset, false, _clearTags()));
            case 21:
              return _ValueBuilder(_createBool(offset, true, _clearTags()));
            case 22:
              return _ValueBuilder(_createNull(offset, _clearTags()));
            case 23:
              return _ValueBuilder(_createUndefined(offset, _clearTags()));

            case 25:
              return _ValueBuilder(_createFloat(
                offset,
                FloatParts.fromFloat16Bytes(header.dataBytes).toDouble(),
                _clearTags(),
              ));

            case 26:
              return _ValueBuilder(_createFloat(
                offset,
                ByteData.view(Uint8List.fromList(header.dataBytes).buffer)
                    .getFloat32(0),
                _clearTags(),
              ));

            case 27:
              return _ValueBuilder(_createFloat(
                offset,
                ByteData.view(Uint8List.fromList(header.dataBytes).buffer)
                    .getFloat64(0),
                _clearTags(),
              ));

            case 31:
              if (allowBreak) {
                if (_clearTags().isNotEmpty && strict) {
                  throw FormatException('Incorrect type for tag', null, offset);
                }

                return _ValueBuilder(const Break());
              } else if (strict) {
                throw FormatException('Unexpected CBOR break.', null, offset);
              } else {
                break;
              }

            default:
              if (header.additionalInfo <= 24) {
                final tags = _clearTags();

                if (tags.isNotEmpty && strict) {
                  throw FormatException('Incorrect type for tag', null, offset);
                }
                return _ValueBuilder(
                    CborSimpleValue(header.info.toInt(), tags));
              } else if (strict) {
                throw FormatException('Bad CBOR value.', null, offset);
              } else {
                break;
              }
          }
      }
    }
  }

  CborString _createString(int offset, String string, List<int> tags) {
    final CborString cbor;
    switch (_parseTags<String>(tags, offset)) {
      case CborTag.dateTimeString:
        cbor = CborDateTimeString.fromString(string, tags);
        break;
      case CborTag.uri:
        cbor = CborUri.fromString(string, tags);
        break;
      case CborTag.base64Url:
        cbor = CborBase64Url.fromString(string, tags);
        break;
      case CborTag.base64:
        cbor = CborBase64.fromString(string, tags);
        break;
      case CborTag.regex:
        cbor = CborRegex.fromString(string, tags);
        break;
      case CborTag.mime:
        cbor = CborMime.fromString(string, tags);
        break;
      default:
        cbor = CborString(string, tags);
        break;
    }
    if (strict) {
      cbor.verify();
    }

    return cbor;
  }

  CborBytes _createBytes(int offset, List<int> bytes, List<int> tags) {
    switch (_parseTags<List<int>>(tags, offset)) {
      case CborTag.positiveBignum:
        return CborBigInt.fromBytes(bytes, tags);
      case CborTag.negativeBignum:
        return CborBigInt.fromNegativeBytes(bytes, tags);
      default:
        return CborBytes(bytes, tags);
    }
  }

  CborInt _createInt(int offset, Info value, List<int> tags) {
    if (_parseTags<int>(tags, offset) == CborTag.epochDateTime) {
      return CborDateTimeInt.fromSecondsSinceEpoch(value.toInt(), tags);
    } else if (value.bitLength < 53) {
      return CborSmallInt(value.toInt());
    } else {
      return CborInt(value.toBigInt());
    }
  }

  CborFloat _createFloat(int offset, double value, List<int> tags) {
    if (_parseTags<double>(tags, offset) == CborTag.epochDateTime) {
      return CborDateTimeFloat.fromSecondsSinceEpoch(value, tags);
    } else {
      return CborFloat(value, tags);
    }
  }

  CborList _createList(int offset, List<CborValue> items, List<int> tags) {
    switch (_parseTags<List<CborValue>>(tags, offset, items)) {
      case CborTag.decimalFraction:
        if (items.length != 2) {
          break;
        }

        final exponent = items[0];
        final mantissa = items[1];

        if (exponent is! CborInt ||
            mantissa is! CborInt ||
            (strict && exponent is CborBigInt)) {
          break;
        }

        return CborDecimalFraction(exponent, mantissa, tags);

      case CborTag.bigFloat:
        if (items.length != 2) {
          break;
        }

        final exponent = items[0];
        final mantissa = items[1];

        if (exponent is! CborInt ||
            mantissa is! CborInt ||
            (strict && exponent is CborBigInt)) {
          break;
        }

        return CborBigFloat(exponent, mantissa, tags);
    }

    return CborList(items, tags);
  }

  CborBool _createBool(int offset, bool value, List<int> tags) {
    _parseTags<bool>(tags, offset);
    return CborBool(value, tags);
  }

  CborUndefined _createUndefined(int offset, List<int> tags) {
    _parseTags<Null>(tags, offset);
    return CborUndefined(tags);
  }

  CborNull _createNull(int offset, List<int> tags) {
    _parseTags<Null>(tags, offset);
    return CborNull(tags);
  }

  int _parseTags<T>(List<int> tags, int offset, [T? value]) {
    var subtype = -1;

    var expectConversion = -1;
    for (final h in tags.reversed) {
      if (isHintSubtype(h)) {
        if (subtype != -1) {
          if (strict) {
            throw _IncompatibleTagException(offset);
          }
        } else {
          subtype = h;
        }
      }

      if (strict) {
        if (isExpectConversion(h)) {
          if (expectConversion != -1) {
            throw _IncompatibleTagException(offset);
          } else {
            expectConversion = h;
          }
        }

        switch (h) {
          case CborTag.uri:
          case CborTag.base64Url:
          case CborTag.base64:
          case CborTag.regex:
          case CborTag.mime:
          case CborTag.dateTimeString:
            if (!isSubtype<T, String>()) {
              throw _IncompatibleTagException(offset);
            }

            break;

          case CborTag.epochDateTime:
            if (!isSubtype<T, num>()) {
              throw _IncompatibleTagException(offset);
            }

            break;

          case CborTag.positiveBignum:
          case CborTag.negativeBignum:
          case CborTag.encodedCborData:
            if (!isSubtype<T, List<int>>()) {
              throw _IncompatibleTagException(offset);
            }

            break;

          case CborTag.decimalFraction:
          case CborTag.bigFloat:
            if (value is! List<CborValue> ||
                value.length != 2 ||
                value[0] is! CborInt ||
                value[1] is! CborInt ||
                value[0] is CborBigInt) {
              throw _IncompatibleTagException(offset);
            }

            break;
        }
      }
    }

    return subtype;
  }
}

abstract class Builder {
  CborValue? poll();
}

class _ValueBuilder implements Builder {
  _ValueBuilder(this._ready);

  final CborValue _ready;

  @override
  CborValue? poll() => _ready;
}

class _BytesBuilder implements Builder {
  _BytesBuilder(this.offset, this.d, this.tags, this.size)
      : bytes = Uint8List(size);

  final BuilderReader d;
  final int offset;
  final List<int> tags;
  final int size;
  final Uint8List bytes;
  int current = 0;

  @override
  CborValue? poll() {
    final add = d._reader.readBytes(size - current);
    bytes.setRange(current, add.length, add);
    current += add.length;

    if (current != size) {
      return null;
    }

    return d._createBytes(offset, bytes, tags);
  }
}

class _IndefiniteBytesBuilder implements Builder {
  _IndefiniteBytesBuilder(this.offset, this.d, this.tags);

  final BuilderReader d;
  final Uint8Buffer bytes = Uint8Buffer();
  final List<int> tags;
  Builder? next;
  final int offset;

  @override
  CborValue? poll() {
    while (true) {
      next ??= d.read(true);
      final value = next?.poll();
      if (value == null) {
        return null;
      }

      if (value is Break) {
        return d._createBytes(offset, bytes, tags);
      }

      if (value is! CborBytes || (next is! _BytesBuilder && d.strict)) {
        throw FormatException(
            'An indefinite byte string must only contain definite '
            'length byte strings.',
            null,
            offset);
      }

      next = null;

      bytes.addAll(value.bytes);
    }
  }
}

class _StringBuilder implements Builder {
  _StringBuilder(this.offset, this.d, this.tags, this.size) {
    sink = d.utf8.decoder.startChunkedConversion(
      StringConversionSink.withCallback((accumulated) {
        data.write(accumulated);
      }),
    );
  }

  final BuilderReader d;
  final List<int> tags;
  final int size;
  final StringBuffer data = StringBuffer();
  late final ByteConversionSink sink;
  int current = 0;
  final int offset;

  @override
  CborValue? poll() {
    final add = d._reader.readBytes(size - current);
    sink.add(add);
    current += add.length;

    if (current != size) {
      return null;
    }

    sink.close();

    return d._createString(offset, data.toString(), tags);
  }
}

class _IndefiniteStringBuilder implements Builder {
  _IndefiniteStringBuilder(this.offset, this.d, this.tags);

  final BuilderReader d;
  final StringBuffer data = StringBuffer();
  final List<int> tags;
  Builder? next;
  final int offset;

  @override
  CborValue? poll() {
    while (true) {
      next ??= d.read(true);
      final value = next?.poll();
      if (value == null) {
        return null;
      }

      if (value is Break) {
        return d._createString(offset, data.toString(), tags);
      }

      if (value is! CborString || (next is! _StringBuilder && d.strict)) {
        throw FormatException(
            'An indefinite length string must only contain definite '
            'length strings.',
            null,
            offset);
      }

      next = null;

      data.write(value.toString());
    }
  }
}

abstract class _ItemsBuilder implements Builder {
  _ItemsBuilder(this.d, this.tags);

  final BuilderReader d;
  final List<int> tags;
  final List<CborValue> items = [];
  Builder? _next;

  bool get allowBreak;
  bool get isDone;

  @override
  CborValue? poll() {
    while (!isDone || _next != null) {
      _next ??= d.read(allowBreak);

      final value = _next?.poll();
      if (value == null) {
        return null;
      }
      items.add(value);
      _next = null;
    }

    return finish();
  }

  CborValue? finish();
}

class _ListBuilder extends _ItemsBuilder {
  _ListBuilder(this.offset, BuilderReader d, this.size, List<int> tags)
      : super(d, tags);

  final int size;
  final int offset;

  @override
  final bool allowBreak = false;

  @override
  bool get isDone => items.length == size;

  @override
  CborValue? finish() {
    return d._createList(offset, items, tags);
  }
}

class _IndefiniteListBuilder extends _ItemsBuilder {
  _IndefiniteListBuilder(this.offset, BuilderReader d, List<int> tags)
      : super(d, tags);

  @override
  final bool allowBreak = true;
  final int offset;

  @override
  bool get isDone => items.lastOrNull is Break;

  @override
  CborValue? finish() {
    items.removeLast();
    return d._createList(offset, items, tags);
  }
}

class _MapBuilder extends _ItemsBuilder {
  _MapBuilder(this.offset, BuilderReader d, this.size, List<int> tags)
      : super(d, tags);

  final int size;
  final int offset;

  @override
  final bool allowBreak = false;

  @override
  bool get isDone => items.length == 2 * size;

  @override
  CborValue? finish() {
    if (d.strict) {
      var keySet = <CborValue>{};

      for (var i = 0; i < size; i++) {
        if (!keySet.add(items[i * 2])) {
          throw FormatException('Duplicate key.', null, offset);
        }
      }
    }

    return CborMap.fromEntries(
      Iterable.generate(size)
          .map((index) => MapEntry(items[index * 2], items[index * 2 + 1])),
      tags,
    );
  }
}

class _IndefiniteMapBuilder extends _ItemsBuilder {
  _IndefiniteMapBuilder(this.offset, BuilderReader d, List<int> tags)
      : super(d, tags);

  @override
  final bool allowBreak = true;
  final int offset;

  @override
  bool get isDone => items.lastOrNull is Break;

  @override
  CborValue? finish() {
    if (d.strict && (items.length - 1) % 2 != 0) {
      throw FormatException('Map has more keys than values', null, offset);
    }

    return CborMap.fromEntries(
      Iterable.generate((items.length - 1) ~/ 2)
          .map((index) => MapEntry(items[index * 2], items[index * 2 + 1])),
      tags,
    );
  }
}
