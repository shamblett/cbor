/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/internal.dart';
import 'package:collection/collection.dart';
import 'package:ieee754/ieee754.dart';

import '../utils/utils.dart';
import '../constants.dart';
import 'stage2.dart';

class CborSink implements Sink<RawValueTagged> {
  final Sink<CborValue> _sink;
  _Builder? _next;

  CborSink(this._sink);

  @override
  void add(RawValueTagged data) {
    final _Builder builder;
    switch (data.header.majorType) {
      case CborMajorType.uint:
      case CborMajorType.nint:
        builder = _ValueBuilder(_createInt(data));
        break;

      case CborMajorType.byteString:
        builder =
            data.header.arg.isIndefiniteLength
                ? _IndefiniteLengthByteBuilder(data)
                : _ValueBuilder(
                  _createBytes(data.data, data.offset, data.tags),
                );
        break;

      case CborMajorType.textString:
        builder =
            data.header.arg.isIndefiniteLength
                ? _IndefiniteLengthStringBuilder(data)
                : _ValueBuilder(
                  _createString(data.data, data.offset, data.tags),
                );
        break;

      case CborMajorType.array:
        builder =
            data.header.arg.isIndefiniteLength
                ? _IndefiniteLengthListBuilder(data)
                : _ListBuilder(data);
        break;

      case CborMajorType.map:
        builder =
            data.header.arg.isIndefiniteLength
                ? _IndefiniteLengthMapBuilder(data)
                : _MapBuilder(data);
        break;

      case CborMajorType.tag:
        throw Error();

      case CborMajorType.simpleFloat:
        switch (data.header.additionalInfo) {
          case CborAdditionalInfo.simpleFalse:
          case CborAdditionalInfo.simpleTrue:
            builder = _ValueBuilder(_createBool(data));
            break;
          case CborAdditionalInfo.simpleNull:
            builder = _ValueBuilder(_createNull(data));
            break;
          case CborAdditionalInfo.simpleUndefined:
            builder = _ValueBuilder(_createUndefined(data));
            break;

          case CborAdditionalInfo.halfPrecisionFloat:
          case CborAdditionalInfo.singlePrecisionFloat:
          case CborAdditionalInfo.doublePrecisionFloat:
            builder = _ValueBuilder(_createFloat(data));
            break;

          case CborAdditionalInfo.breakStop:
            builder = _ValueBuilder(const Break());
            break;

          default:
            if (data.header.additionalInfo <=
                CborAdditionalInfo.simpleValueHigh) {
              builder = _ValueBuilder(
                CborSimpleValue(data.header.arg.toInt(), tags: data.tags),
              );
            } else {
              throw CborMalformedException(
                'Reserved simple value',
                data.offset,
              );
            }

            break;
        }

        break;

      default:
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

CborString _createString(List<int> str, int _, List<int> tags) {
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

CborBytes _createBytes(List<int> data, int _, List<int> tags) {
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
    case CborAdditionalInfo.halfPrecisionFloat:
      value = FloatParts.fromFloat16Bytes(raw.header.dataBytes).toDouble();
      break;
    case CborAdditionalInfo.singlePrecisionFloat:
      value = FloatParts.fromFloat32Bytes(raw.header.dataBytes).toDouble();
      break;
    case CborAdditionalInfo.doublePrecisionFloat:
      value = FloatParts.fromFloat64Bytes(raw.header.dataBytes).toDouble();
      break;

    default:
      throw Error();
  }

  return raw.tags.lastWhereOrNull(isHintSubtype) == CborTag.epochDateTime
      ? CborDateTimeFloat.fromSecondsSinceEpoch(value, tags: raw.tags)
      : CborFloat(value, tags: raw.tags);
}

CborList _createList(
  RawValueTagged raw,
  List<CborValue> items,
  CborLengthType type,
) {
  switch (raw.tags.lastWhereOrNull(isHintSubtype)) {
    case CborTag.rationalNumber:
      if (items.length != CborConstants.two) {
        break;
      }

      final numerator = items.first;
      final denominator = items[1];

      if (numerator is! CborInt ||
          denominator is! CborInt ||
          denominator.toInt() == 0) {
        break;
      }

      return CborRationalNumber(
        numerator: numerator,
        denominator: denominator,
        tags: raw.tags,
        type: type,
      );
    case CborTag.decimalFraction:
      if (items.length != CborConstants.two) {
        break;
      }

      final exponent = items.first;
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
        type: type,
      );

    case CborTag.bigFloat:
      if (items.length != CborConstants.two) {
        break;
      }

      final exponent = items.first;
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
        type: type,
      );
  }

  return CborList(items, tags: raw.tags, type: type);
}

CborMap _createMap(
  RawValueTagged raw,
  List<CborValue> items,
  CborLengthType type,
) {
  if (items.length % CborConstants.two != 0) {
    throw CborMalformedException('Map has more keys than values', raw.offset);
  }

  return CborMap.fromEntries(
    items.chunks(CborConstants.two).map((x) => MapEntry(x.first, x[1])),
    tags: raw.tags,
    type: type,
  );
}

CborBool _createBool(RawValueTagged raw) {
  final value = raw.header.additionalInfo != CborAdditionalInfo.simpleFalse;
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
  final CborValue data;

  @override
  final bool isDone = true;

  _ValueBuilder(this.data);

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
  final RawValueTagged raw;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == raw.header.arg.toInt();

  _ListBuilder(this.raw);

  @override
  void add(_Builder builder) {
    final next = _next;
    if (next != null) {
      next.add(builder);
      if (next.isDone) {
        items.add(next.build());
        _next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();
      if (value is Break) {
        throw _CborUnexpectedBreakException(raw.offset);
      }

      items.add(value);
    } else {
      _next = builder;
    }
  }

  @override
  CborValue build() {
    return _createList(raw, items, CborLengthType.definite);
  }
}

class _MapBuilder extends _Builder {
  final RawValueTagged raw;
  final List<CborValue> items = [];
  _Builder? _next;

  @override
  bool get isDone => items.length == CborConstants.two * raw.header.arg.toInt();

  _MapBuilder(this.raw);

  @override
  void add(_Builder builder) {
    final next = _next;
    if (next != null) {
      next.add(builder);
      if (next.isDone) {
        items.add(next.build());
        _next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();
      if (value is Break) {
        throw _CborUnexpectedBreakException(raw.offset);
      }

      items.add(value);
    } else {
      _next = builder;
    }
  }

  @override
  CborValue build() {
    return _createMap(raw, items, CborLengthType.definite);
  }
}

class _IndefiniteLengthByteBuilder extends _Builder {
  final RawValueTagged raw;
  final List<List<int>> bytes = [];

  @override
  bool isDone = false;

  _IndefiniteLengthByteBuilder(this.raw);

  @override
  void add(_Builder builder) {
    if (builder is _ValueBuilder) {
      final value = builder.build();
      if (value is Break) {
        isDone = true;
        return;
      } else if (value is CborBytes) {
        bytes.add(value.bytes);
        return;
      }
    }

    throw CborMalformedException(
      'An indefinite byte string must only contain byte strings.',
      raw.offset,
    );
  }

  @override
  CborValue build() {
    return CborBytes.indefinite(bytes, tags: raw.tags);
  }
}

class _IndefiniteLengthStringBuilder extends _Builder {
  final RawValueTagged raw;
  final List<List<int>> bytes = [];

  @override
  bool isDone = false;

  _IndefiniteLengthStringBuilder(this.raw);

  @override
  void add(_Builder builder) {
    if (builder is _ValueBuilder) {
      final value = builder.build();
      if (value is Break) {
        isDone = true;
        return;
      } else if (value is CborString) {
        bytes.add(value.utf8Bytes);
        return;
      }
    }

    throw CborMalformedException(
      'An indefinite string must only contain strings.',
      raw.offset,
    );
  }

  @override
  CborValue build() {
    return CborString.indefiniteFromUtf8(bytes, tags: raw.tags);
  }
}

class _IndefiniteLengthListBuilder extends _Builder {
  final RawValueTagged raw;
  final List<CborValue> items = [];

  @override
  bool isDone = false;

  _Builder? _next;

  _IndefiniteLengthListBuilder(this.raw);

  @override
  void add(_Builder builder) {
    final next = _next;
    if (next != null) {
      next.add(builder);
      if (next.isDone) {
        items.add(next.build());
        _next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();

      if (value is Break) {
        isDone = true;
      } else {
        items.add(builder.build());
      }
    } else {
      _next = builder;
    }
  }

  @override
  CborValue build() {
    return _createList(raw, items, CborLengthType.indefinite);
  }
}

class _IndefiniteLengthMapBuilder extends _Builder {
  final RawValueTagged raw;
  final List<CborValue> items = [];

  @override
  bool isDone = false;

  _Builder? _next;

  _IndefiniteLengthMapBuilder(this.raw);

  @override
  void add(_Builder builder) {
    final next = _next;
    if (next != null) {
      next.add(builder);
      if (next.isDone) {
        items.add(next.build());
        _next = null;
      }
    } else if (builder.isDone) {
      final value = builder.build();

      if (value is Break) {
        isDone = true;
      } else {
        items.add(builder.build());
      }
    } else {
      _next = builder;
    }
  }

  @override
  CborValue build() {
    return _createMap(raw, items, CborLengthType.indefinite);
  }
}
