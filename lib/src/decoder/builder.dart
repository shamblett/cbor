/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:ieee754/ieee754.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/info.dart';
import 'reader.dart';

class _Break implements CborValue {
  const _Break();

  @override
  final Iterable<int> hints = const [];
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
    _tags = const [];
    return tags;
  }

  Builder? read([bool allowBreak = false]) {
    Header? header;

    while ((header = _reader.readHeader()) != null) {
      switch (header!.majorType) {
        case 0: // uint
          return _ValueBuilder(_createInt(header.info, _clearTags()));
        case 1: // negative
          return _ValueBuilder(_createInt(~header.info, _clearTags()));

        case 2: // bytes
          if (header.info.isIndefiniteLength) {
            return _IndefiniteBytesBuilder(this, _clearTags());
          } else {
            return _BytesBuilder(this, _clearTags(), header.info.toInt());
          }

        case 3: // string
          if (header.info.isIndefiniteLength) {
            return _IndefiniteStringBuilder(this, _clearTags());
          } else {
            return _StringBuilder(this, _clearTags(), header.info.toInt());
          }

        case 4: // array
          if (header.info.isIndefiniteLength) {
            return _IndefiniteListBuilder(this, _clearTags());
          } else {
            return _ListBuilder(this, header.info.toInt(), _clearTags());
          }

        case 5: // map
          if (header.info.isIndefiniteLength) {
            return _IndefiniteMapBuilder(this, _clearTags());
          } else {
            return _MapBuilder(this, header.info.toInt(), _clearTags());
          }

        case 6: // tags
          _tags.add(header.info.toInt());
          break;

        case 7:
          switch (header.additionalInfo) {
            case 20:
              return _ValueBuilder(_createBool(false, _clearTags()));
            case 21:
              return _ValueBuilder(_createBool(true, _clearTags()));
            case 22:
              return _ValueBuilder(_createNull(_clearTags()));
            case 23:
              return _ValueBuilder(_createUndefined(_clearTags()));

            case 25:
              return _ValueBuilder(_createFloat(
                FloatParts.fromFloat16Bytes(header.dataBytes).toDouble(),
                _clearTags(),
              ));

            case 26:
              return _ValueBuilder(_createFloat(
                ByteData.view(Uint8List.fromList(header.dataBytes).buffer)
                    .getFloat32(0),
                _clearTags(),
              ));

            case 27:
              return _ValueBuilder(_createFloat(
                ByteData.view(Uint8List.fromList(header.dataBytes).buffer)
                    .getFloat64(0),
                _clearTags(),
              ));

            case 31:
              if (allowBreak) {
                if (_clearTags().isNotEmpty && strict) {
                  throw FormatException('Incorrect type for tag');
                }

                return _ValueBuilder(const _Break());
              } else if (strict) {
                throw FormatException('Unexpected CBOR break.');
              } else {
                break;
              }

            default:
              if (header.additionalInfo <= 24) {
                final tags = _clearTags();

                if (tags.isNotEmpty && strict) {
                  throw FormatException('Incorrect type for tag');
                }
                return _ValueBuilder(
                    CborSimpleValue(header.info.toInt(), tags));
              } else if (strict) {
                throw FormatException('Bad CBOR value.');
              } else {
                break;
              }
          }
      }
    }
  }

  CborString _createString(String string, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<String>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    final CborString cbor;
    switch (tags.lastOrNull) {
      case CborHint.dateTimeString:
        cbor = CborDateTimeString.fromString(string, tags);
        break;
      case CborHint.uri:
        cbor = CborUri.fromString(string, tags);
        break;
      case CborHint.base64Url:
        cbor = CborBase64Url.fromString(string, tags);
        break;
      case CborHint.base64:
        cbor = CborBase64.fromString(string, tags);
        break;
      case CborHint.regex:
        cbor = CborRegex.fromString(string, tags);
        break;
      case CborHint.mime:
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

  CborBytes _createBytes(List<int> bytes, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<List<int>>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    switch (tags.lastOrNull) {
      case CborHint.positiveBignum:
        return CborBigInt.fromBytes(bytes, tags);
      case CborHint.negativeBignum:
        return CborBigInt.fromNegativeBytes(bytes, tags);
      default:
        return CborBytes(bytes, tags);
    }
  }

  CborInt _createInt(Info value, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<int>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    if (tags.lastOrNull == CborHint.epochDateTime) {
      return CborDateTimeInt.fromSecondsSinceEpoch(value.toInt(), tags);
    } else if (value.bitLength() < 53) {
      return CborSmallInt(value.toInt());
    } else {
      return CborInt(value.toBigInt());
    }
  }

  CborFloat _createFloat(double value, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<double>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    if (tags.lastOrNull == CborHint.epochDateTime) {
      return CborDateTimeFloat.fromSecondsSinceEpoch(value, tags);
    } else {
      return CborFloat(value, tags);
    }
  }

  CborList _createList(List<CborValue> items, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply(hint, items)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    switch (tags.lastOrNull) {
      case CborHint.decimalFraction:
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

      case CborHint.bigFloat:
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

  CborBool _createBool(bool value, List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<bool>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    return CborBool(value, tags);
  }

  CborUndefined _createUndefined(List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<Null>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    return CborUndefined(tags);
  }

  CborNull _createNull(List<int> tags) {
    if (strict) {
      for (final hint in tags) {
        if (!_canApply<Null>(hint)) {
          throw FormatException('Incorrect type for tag');
        }
      }
    }

    return CborNull(tags);
  }
}

bool _canApply<T>(int tag, [T? value]) {
  switch (tag) {
    case CborHint.uri:
    case CborHint.base64Url:
    case CborHint.base64:
    case CborHint.regex:
    case CborHint.mime:
    case CborHint.dateTimeString:
      return isSubtype<T, String>();

    case CborHint.epochDateTime:
      return isSubtype<T, num>();

    case CborHint.positiveBignum:
    case CborHint.negativeBignum:
    case CborHint.encodedCborData:
      return isSubtype<T, List<int>>();

    case CborHint.decimalFraction:
    case CborHint.bigFloat:
      return value is List<CborValue> &&
          value.length == 2 &&
          value[0] is CborInt &&
          value[1] is CborInt &&
          value[0] is! CborBigInt;

    default:
      return true;
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
  _BytesBuilder(this.d, this.tags, this.size) : bytes = Uint8List(size);

  final BuilderReader d;
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

    return d._createBytes(bytes, tags);
  }
}

class _IndefiniteBytesBuilder implements Builder {
  _IndefiniteBytesBuilder(this.d, this.tags);

  final BuilderReader d;
  final Uint8Buffer bytes = Uint8Buffer();
  final List<int> tags;
  Builder? next;

  @override
  CborValue? poll() {
    while (true) {
      next ??= d.read(true);
      final value = next?.poll();
      if (value == null) {
        return null;
      }

      if (value is _Break) {
        return d._createBytes(bytes, tags);
      }

      if (value is! CborBytes || (next is! _BytesBuilder && d.strict)) {
        throw FormatException(
            'An indefinite byte string must only contain definite '
            'length byte strings.');
      }

      next = null;

      bytes.addAll(value.bytes);
    }
  }
}

class _StringBuilder implements Builder {
  _StringBuilder(this.d, this.tags, this.size) {
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

  @override
  CborValue? poll() {
    final add = d._reader.readBytes(size - current);
    sink.add(add);
    current += add.length;

    if (current != size) {
      return null;
    }

    sink.close();

    return d._createString(data.toString(), tags);
  }
}

class _IndefiniteStringBuilder implements Builder {
  _IndefiniteStringBuilder(this.d, this.tags);

  final BuilderReader d;
  final StringBuffer data = StringBuffer();
  final List<int> tags;
  Builder? next;

  @override
  CborValue? poll() {
    while (true) {
      next ??= d.read(true);
      final value = next?.poll();
      if (value == null) {
        return null;
      }

      if (value is _Break) {
        return d._createString(data.toString(), tags);
      }

      if (value is! CborString || (next is! _StringBuilder && d.strict)) {
        throw FormatException(
            'An indefinite length string must only contain definite '
            'length strings.');
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
  _ListBuilder(BuilderReader d, this.size, List<int> tags) : super(d, tags);

  final int size;

  @override
  final bool allowBreak = false;

  @override
  bool get isDone => items.length == size;

  @override
  CborValue? finish() {
    return d._createList(items, tags);
  }
}

class _IndefiniteListBuilder extends _ItemsBuilder {
  _IndefiniteListBuilder(BuilderReader d, List<int> tags) : super(d, tags);

  @override
  final bool allowBreak = true;

  @override
  bool get isDone => items.lastOrNull is _Break;

  @override
  CborValue? finish() {
    items.removeLast();
    return d._createList(items, tags);
  }
}

class _MapBuilder extends _ItemsBuilder {
  _MapBuilder(BuilderReader d, this.size, List<int> tags) : super(d, tags);

  final int size;

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
          throw FormatException('Duplicate key.');
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
  _IndefiniteMapBuilder(BuilderReader d, List<int> tags) : super(d, tags);

  @override
  final bool allowBreak = true;

  @override
  bool get isDone => items.lastOrNull is _Break;

  @override
  CborValue? finish() {
    return CborMap.fromEntries(
      Iterable.generate((items.length - 1) ~/ 2)
          .map((index) => MapEntry(items[index * 2], items[index * 2 + 1])),
      tags,
    );
  }
}
