/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';
import 'package:cbor/src/value/internal.dart';
import 'package:ieee754/ieee754.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/utils.dart';
import 'stage2.dart';

class CborSink extends Sink<RawValueTagged> {
  CborSink(this._sink);

  final Sink<CborValue> _sink;
  _Builder? _next;

  @override
  void add(RawValueTagged data) {
    final _Builder builder;
    switch (data.header.majorType) {
      case 0: // uint
      case 1: // negative
        builder = _ValueBuilder(_createInt(data));
        break;

      case 2: // bytes
        if (data.header.arg.isIndefiniteLength) {
          builder = _IndefiniteLengthByteBuilder(data);
        } else {
          builder =
              _ValueBuilder(_createBytes(data.data, data.offset, data.tags));
        }
        break;

      case 3: // string
        if (data.header.arg.isIndefiniteLength) {
          builder = _IndefiniteLengthStringBuilder(data);
        } else {
          builder = _ValueBuilder(_createString(
            data.data,
            data.offset,
            data.tags,
          ));
        }
        break;

      case 4: // array
        if (data.header.arg.isIndefiniteLength) {
          builder = _IndefiniteLengthListBuilder(data);
        } else {
          builder = _ListBuilder(data);
        }
        break;

      case 5: // map
        if (data.header.arg.isIndefiniteLength) {
          builder = _IndefiniteLengthMapBuilder(data);
        } else {
          builder = _MapBuilder(data);
        }
        break;

      case 7:
        switch (data.header.additionalInfo) {
          case 20:
          case 21:
            builder = _ValueBuilder(_createBool(data));
            break;
          case 22:
            builder = _ValueBuilder(_createNull(data));
            break;
          case 23:
            builder = _ValueBuilder(_createUndefined(data));
            break;

          case 25:
          case 26:
          case 27:
            builder = _ValueBuilder(_createFloat(data));
            break;

          case 31:
            builder = _ValueBuilder(const Break());
            break;

          default:
            if (data.header.additionalInfo <= 24) {
              builder = _ValueBuilder(
                  CborSimpleValue(data.header.arg.toInt(), tags: data.tags));
            } else {
              throw CborMalformedException(
                  'Reserved simple value', data.offset);
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

      if (value is Break) {
        throw _CborUnexpectedBreakException(data.offset);
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

class _CborUnexpectedBreakException extends CborMalformedException {
  _CborUnexpectedBreakException(int offset) : super('Unexpected break', offset);
}

class _CborUnexpectedUndefinedLengthException extends CborMalformedException {
  _CborUnexpectedUndefinedLengthException(int offset)
      : super('Major type can not be undefined length', offset);
}

CborString _createString(List<int> str, int offset, List<int> tags) {
  final CborString cbor;
  switch (tags.lastWhereOrNull(isHintSubtype)) {
    case CborTag.dateTimeString:
      cbor = CborDateTimeString.fromUtf8(str, tags: tags);
      break;
    case CborTag.uri:
      cbor = CborUri.fromUtf8(str, tags: tags);
      break;
    case CborTag.base64Url:
      cbor = CborBase64Url.fromUtf8(str, tags: tags);
      break;
    case CborTag.base64:
      cbor = CborBase64.fromUtf8(str, tags: tags);
      break;
    case CborTag.regex:
      cbor = CborRegex.fromUtf8(str, tags: tags);
      break;
    case CborTag.mime:
      cbor = CborMime.fromUtf8(str, tags: tags);
      break;
    default:
      cbor = CborString.fromUtf8(str, tags: tags);
      break;
  }

  return cbor;
}

CborBytes _createBytes(List<int> data, int offset, List<int> tags) {
  switch (tags.lastWhereOrNull(isHintSubtype)) {
    case CborTag.positiveBignum:
      return CborBigInt.fromBytes(data, tags: tags);
    case CborTag.negativeBignum:
      return CborBigInt.fromNegativeBytes(data, tags: tags);
    default:
      return CborBytes(data, tags: tags);
  }
}

CborInt _createInt(RawValueTagged raw) {
  var data = raw.header.arg;

  if (data.isIndefiniteLength) {
    throw _CborUnexpectedUndefinedLengthException(raw.offset);
  }

  if (raw.header.majorType == 1) {
    data = ~data;
  }

  if (raw.tags.lastWhereOrNull(isHintSubtype) == CborTag.epochDateTime) {
    return CborDateTimeInt.fromSecondsSinceEpoch(data.toInt(), tags: raw.tags);
  } else if (data.isValidInt) {
    return CborSmallInt(data.toInt());
  } else {
    return CborInt(data.toBigInt());
  }
}

CborFloat _createFloat(RawValueTagged raw) {
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

  if (raw.tags.lastWhereOrNull(isHintSubtype) == CborTag.epochDateTime) {
    return CborDateTimeFloat.fromSecondsSinceEpoch(value, tags: raw.tags);
  } else {
    return CborFloat(value, tags: raw.tags);
  }
}

CborList _createList(RawValueTagged raw, List<CborValue> items) {
  switch (raw.tags.lastWhereOrNull(isHintSubtype)) {
    case CborTag.decimalFraction:
      if (items.length != 2) {
        break;
      }

      final exponent = items[0];
      final mantissa = items[1];

      if (exponent is! CborInt ||
          mantissa is! CborInt ||
          exponent is CborBigInt) {
        break;
      }

      return CborDecimalFraction(
        exponent: exponent,
        mantissa: mantissa,
        tags: raw.tags,
      );

    case CborTag.bigFloat:
      if (items.length != 2) {
        break;
      }

      final exponent = items[0];
      final mantissa = items[1];

      if (exponent is! CborInt ||
          mantissa is! CborInt ||
          exponent is CborBigInt) {
        break;
      }

      return CborBigFloat(
        exponent: exponent,
        mantissa: mantissa,
        tags: raw.tags,
      );
  }

  return CborList(items, tags: raw.tags);
}

CborMap _createMap(RawValueTagged raw, List<CborValue> items) {
  if (items.length % 2 != 0) {
    throw CborMalformedException('Map has more keys than values', raw.offset);
  }

  return CborMap.fromEntries(items.chunks(2).map((x) => MapEntry(x[0], x[1])),
      tags: raw.tags);
}

CborBool _createBool(RawValueTagged raw) {
  final value = raw.header.additionalInfo != 20;
  return CborBool(value, tags: raw.tags);
}

CborUndefined _createUndefined(RawValueTagged raw) {
  return CborUndefined(tags: raw.tags);
}

CborNull _createNull(RawValueTagged raw) {
  return CborNull(tags: raw.tags);
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
  _ListBuilder(this.raw);

  final RawValueTagged raw;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == raw.header.arg.toInt();

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
        throw _CborUnexpectedBreakException(raw.offset);
      }

      items.add(value);
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createList(raw, items);
  }
}

class _MapBuilder extends _Builder {
  _MapBuilder(this.raw);

  final RawValueTagged raw;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == 2 * raw.header.arg.toInt();

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
        throw _CborUnexpectedBreakException(raw.offset);
      }

      items.add(value);
    } else {
      this._next = builder;
    }
  }

  @override
  CborValue build() {
    return _createMap(raw, items);
  }
}

class _IndefiniteLengthByteBuilder extends _Builder {
  _IndefiniteLengthByteBuilder(this.raw);

  final RawValueTagged raw;
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

    throw CborMalformedException(
        'An indefinite byte string must only contain byte strings.',
        raw.offset);
  }

  @override
  CborValue build() {
    return _createBytes(bytes, raw.offset, raw.tags);
  }
}

class _IndefiniteLengthStringBuilder extends _Builder {
  _IndefiniteLengthStringBuilder(this.raw);

  final RawValueTagged raw;
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
      } else if (value is CborString) {
        bytes.addAll(value.utf8Bytes);
        return;
      }
    }

    throw CborMalformedException(
        'An indefinite string must only contain strings.', raw.offset);
  }

  @override
  CborValue build() {
    return _createString(bytes, raw.offset, raw.tags);
  }
}

class _IndefiniteLengthListBuilder extends _Builder {
  _IndefiniteLengthListBuilder(this.raw);

  final RawValueTagged raw;
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
    return _createList(raw, items);
  }
}

class _IndefiniteLengthMapBuilder extends _Builder {
  _IndefiniteLengthMapBuilder(this.raw);

  final RawValueTagged raw;
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
    return _createMap(raw, items);
  }
}
