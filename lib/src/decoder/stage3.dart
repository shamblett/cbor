import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/internal.dart';
import 'package:ieee754/ieee754.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/utils.dart';
import 'stage2.dart';

class CborSink extends Sink<RawValueTagged> {
  CborSink(this._strict, this._sink);

  final bool _strict;
  final Sink<CborValue> _sink;
  _Builder? _next;

  @override
  void add(RawValueTagged data) {
    final _Builder builder;
    switch (data.header.majorType) {
      case 0: // uint
      case 1: // negative
        builder = _ValueBuilder(_createInt(_strict, data));
        break;

      case 2: // bytes
        if (data.header.info.isIndefiniteLength) {
          builder = _IndefiniteLengthByteBuilder(_strict, data);
        } else {
          builder = _ValueBuilder(
              _createBytes(_strict, data.data, data.offset, data.tags));
        }
        break;

      case 3: // string
        if (data.header.info.isIndefiniteLength) {
          builder = _IndefiniteLengthStringBuilder(_strict, data);
        } else if (_strict) {
          builder = _ValueBuilder(_createString(
            _strict,
            (const Utf8Codec(allowMalformed: false)).decode(data.data),
            data.offset,
            data.tags,
          ));
        } else {
          builder = _ValueBuilder(_createString(
            _strict,
            (const Utf8Codec(allowMalformed: true)).decode(data.data),
            data.offset,
            data.tags,
          ));
        }
        break;

      case 4: // array
        if (data.header.info.isIndefiniteLength) {
          builder = _IndefiniteLengthListBuilder(_strict, data);
        } else {
          builder = _ListBuilder(_strict, data);
        }
        break;

      case 5: // map
        if (data.header.info.isIndefiniteLength) {
          builder = _IndefiniteLengthMapBuilder(_strict, data);
        } else {
          builder = _MapBuilder(_strict, data);
        }
        break;

      case 7:
        switch (data.header.additionalInfo) {
          case 20:
          case 21:
            builder = _ValueBuilder(_createBool(_strict, data));
            break;
          case 22:
            builder = _ValueBuilder(_createNull(_strict, data));
            break;
          case 23:
            builder = _ValueBuilder(_createUndefined(_strict, data));
            break;

          case 25:
          case 26:
          case 27:
            builder = _ValueBuilder(_createFloat(_strict, data));
            break;

          case 31:
            if (data.tags.isNotEmpty) {
              throw CborDecodeException('Type accepts no tags', data.offset);
            }

            builder = _ValueBuilder(const Break());
            break;

          default:
            if (data.header.additionalInfo <= 24) {
              if (data.tags.isNotEmpty) {
                throw CborDecodeException('Type accepts no tags', data.offset);
              }

              builder = _ValueBuilder(
                  CborSimpleValue(data.header.info.toInt(), data.tags));
            } else if (_strict) {
              throw CborDecodeException('Bad CBOR value.', data.offset);
            } else {
              return;
            }

            break;
        }

        break;

      default: // tags
        throw Error();
    }

    if (_next != null) {
      _next!.add(builder);

      if (_next!.isDone) {
        final built = _next!.build();
        _next = null;
        _sink.add(built);

        return;
      }
    } else if (builder.isDone) {
      final value = builder.build();

      if (value is Break && _strict) {
        throw CborDecodeException('Unexpected CBOR break', data.offset);
      }

      _sink.add(value);
    } else {
      _next = builder;
    }
  }

  @override
  void close() {
    _sink.close();
  }
}

class _IncompatibleTagException extends CborDecodeException {
  _IncompatibleTagException(int offset) : super('Incompatible tags', offset);
}

CborString _createString(bool strict, String data, int offset, List<int> tags) {
  final CborString cbor;
  switch (_parseTags<CborString>(strict, offset, tags)) {
    case CborTag.dateTimeString:
      cbor = CborDateTimeString.fromString(data, tags);
      break;
    case CborTag.uri:
      cbor = CborUri.fromString(data, tags);
      break;
    case CborTag.base64Url:
      cbor = CborBase64Url.fromString(data, tags);
      break;
    case CborTag.base64:
      cbor = CborBase64.fromString(data, tags);
      break;
    case CborTag.regex:
      cbor = CborRegex.fromString(data, tags);
      break;
    case CborTag.mime:
      cbor = CborMime.fromString(data, tags);
      break;
    default:
      cbor = CborString(data, tags);
      break;
  }
  if (strict) {
    try {
      cbor.verify();
    } on FormatException catch (ex) {
      throw CborFormatException(ex, offset);
    }
  }

  return cbor;
}

CborBytes _createBytes(
    bool strict, List<int> data, int offset, List<int> tags) {
  switch (_parseTags<CborBytes>(strict, offset, tags)) {
    case CborTag.positiveBignum:
      return CborBigInt.fromBytes(data, tags);
    case CborTag.negativeBignum:
      return CborBigInt.fromNegativeBytes(data, tags);
    default:
      return CborBytes(data, tags);
  }
}

CborInt _createInt(bool strict, RawValueTagged raw) {
  var data = raw.header.info;

  if (raw.header.majorType == 1) {
    data = ~data;
  }

  if (_parseTags<CborInt>(strict, raw.offset, raw.tags) ==
      CborTag.epochDateTime) {
    return CborDateTimeInt.fromSecondsSinceEpoch(data.toInt(), raw.tags);
  } else if (data.bitLength < 53) {
    return CborSmallInt(data.toInt());
  } else {
    return CborInt(data.toBigInt());
  }
}

CborFloat _createFloat(bool strict, RawValueTagged raw) {
  final double value;
  switch (raw.header.additionalInfo) {
    case 25:
      value = FloatParts.fromFloat16Bytes(raw.header.dataBytes).toDouble();
      break;
    case 26:
      value = FloatParts.fromFloat32Bytes(raw.header.dataBytes).toDouble();
      break;
    case 27:
      value = FloatParts.fromFloat64Bytes(raw.header.dataBytes).toDouble();
      break;

    default:
      throw Error();
  }

  if (_parseTags<CborFloat>(strict, raw.offset, raw.tags) ==
      CborTag.epochDateTime) {
    return CborDateTimeFloat.fromSecondsSinceEpoch(value, raw.tags);
  } else {
    return CborFloat(value, raw.tags);
  }
}

CborList _createList(bool strict, RawValueTagged raw, List<CborValue> items) {
  switch (_parseTags<CborList>(strict, raw.offset, raw.tags, items)) {
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

      return CborDecimalFraction(exponent, mantissa, raw.tags);

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

      return CborBigFloat(exponent, mantissa, raw.tags);
  }

  return CborList(items, raw.tags);
}

CborMap _createMap(bool strict, RawValueTagged raw, List<CborValue> items) {
  _parseTags<CborMap>(strict, raw.offset, raw.tags);

  if (strict && items.length % 2 != 0) {
    throw CborDecodeException('Map has more keys than values', raw.offset);
  }

  return CborMap.fromEntries(
      items.chunks(2).map((x) => MapEntry(x[0], x[1])), raw.tags);
}

CborBool _createBool(bool strict, RawValueTagged raw) {
  final value = raw.header.additionalInfo != 20;

  _parseTags<CborBool>(strict, raw.offset, raw.tags);
  return CborBool(value, raw.tags);
}

CborUndefined _createUndefined(bool strict, RawValueTagged raw) {
  _parseTags<CborUndefined>(strict, raw.offset, raw.tags);
  return CborUndefined(raw.tags);
}

CborNull _createNull(bool strict, RawValueTagged raw) {
  _parseTags<CborNull>(strict, raw.offset, raw.tags);
  return CborNull(raw.tags);
}

int _parseTags<T>(bool strict, int offset, List<int> tags,
    [List<CborValue>? value]) {
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
          if (!isSubtype<T, CborString>()) {
            throw _IncompatibleTagException(offset);
          }

          break;

        case CborTag.epochDateTime:
          if ((!isSubtype<T, CborInt>() || isSubtype<T, CborBigInt>()) &&
              !isSubtype<T, CborFloat>()) {
            throw _IncompatibleTagException(offset);
          }

          break;

        case CborTag.positiveBignum:
        case CborTag.negativeBignum:
        case CborTag.encodedCborData:
          if (!isSubtype<T, CborBytes>()) {
            throw _IncompatibleTagException(offset);
          }

          break;

        case CborTag.decimalFraction:
        case CborTag.bigFloat:
          if (value?.length != 2 ||
              value![0] is! CborInt ||
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

abstract class _Builder {
  bool get isDone;
  void add(_Builder builder);
  CborValue build();
}

class _ValueBuilder extends _Builder {
  _ValueBuilder(this.data);

  final CborValue data;

  @override
  final bool isDone = true;

  @override
  void add(_Builder builder) {
    throw Error();
  }

  @override
  CborValue build() {
    return data;
  }
}

class _ListBuilder extends _Builder {
  _ListBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == raw.header.info.toInt();

  @override
  void add(_Builder builder) {
    final _next = this._next;
    if (_next != null) {
      _next.add(builder);
      if (_next.isDone) {
        items.add(_next.build());
        this._next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();
      if (value is Break && strict) {
        throw CborDecodeException('Unexpected CBOR break', raw.offset);
      }

      items.add(value);
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createList(strict, raw, items);
  }
}

class _MapBuilder extends _Builder {
  _MapBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == 2 * raw.header.info.toInt();

  @override
  void add(_Builder builder) {
    final _next = this._next;
    if (_next != null) {
      _next.add(builder);
      if (_next.isDone) {
        items.add(_next.build());
        this._next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();
      if (value is Break && strict) {
        throw CborDecodeException('Unexpected CBOR break', raw.offset);
      }

      items.add(value);
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createMap(strict, raw, items);
  }
}

class _IndefiniteLengthByteBuilder extends _Builder {
  _IndefiniteLengthByteBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final Uint8Buffer bytes = Uint8Buffer();

  @override
  bool isDone = false;

  @override
  void add(_Builder builder) {
    if (builder is _ValueBuilder) {
      final value = builder.build();
      if (value is Break) {
        isDone = true;
        return;
      } else if (value is CborBytes) {
        bytes.addAll(value.bytes);
        return;
      }
    }

    throw CborDecodeException(
        'An indefinite byte string must only contain byte strings.',
        raw.offset);
  }

  @override
  CborValue build() {
    return _createBytes(strict, bytes, raw.offset, raw.tags);
  }
}

class _IndefiniteLengthStringBuilder extends _Builder {
  _IndefiniteLengthStringBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final StringBuffer accumulated = StringBuffer();

  @override
  bool isDone = false;

  @override
  void add(_Builder builder) {
    if (builder is _ValueBuilder) {
      final value = builder.build();
      if (value is Break) {
        isDone = true;
        return;
      } else if (value is CborString) {
        accumulated.write(value);
        return;
      }
    }

    throw CborDecodeException(
        'An indefinite string must only contain strings.', raw.offset);
  }

  @override
  CborValue build() {
    return _createString(strict, accumulated.toString(), raw.offset, raw.tags);
  }
}

class _IndefiniteLengthListBuilder extends _Builder {
  _IndefiniteLengthListBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool isDone = false;

  @override
  void add(_Builder builder) {
    final _next = this._next;
    if (_next != null) {
      _next.add(builder);
      if (_next.isDone) {
        items.add(_next.build());
        this._next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();

      if (value is Break) {
        isDone = true;
      } else {
        items.add(builder.build());
      }
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createList(strict, raw, items);
  }
}

class _IndefiniteLengthMapBuilder extends _Builder {
  _IndefiniteLengthMapBuilder(this.strict, this.raw);

  final RawValueTagged raw;
  final bool strict;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool isDone = false;

  @override
  void add(_Builder builder) {
    final _next = this._next;
    if (_next != null) {
      _next.add(builder);
      if (_next.isDone) {
        items.add(_next.build());
        this._next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();

      if (value is Break) {
        isDone = true;
      } else {
        items.add(builder.build());
      }
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createMap(strict, raw, items);
  }
}
