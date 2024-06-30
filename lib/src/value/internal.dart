/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

// This is for internal usage and should not be returned to the user

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';

class ToObjectOptions {
  ToObjectOptions({
    required this.parseDateTime,
    required this.parseUri,
    required this.decodeBase64,
    required this.allowMalformedUtf8,
  });

  final bool parseDateTime;
  final bool parseUri;
  final bool decodeBase64;
  final bool allowMalformedUtf8;
}

class ToJsonOptions {
  ToJsonOptions({
    required this.encoding,
    this.substituteValue,
    required this.allowMalformedUtf8,
  });

  ToJsonOptions copyWith({
    JsonBytesEncoding? encoding,
  }) =>
      ToJsonOptions(
        encoding: encoding ?? this.encoding,
        substituteValue: substituteValue,
        allowMalformedUtf8: allowMalformedUtf8,
      );

  final JsonBytesEncoding encoding;
  final bool allowMalformedUtf8;
  final Object? substituteValue;
}

enum JsonBytesEncoding {
  base64Url,

  base64,

  base16,
}

@internal
class Break with CborValueMixin implements CborValue {
  const Break();

  @override
  final List<int> tags = const [];

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    throw UnimplementedError();
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    throw UnimplementedError();
  }

  @override
  void encode(EncodeSink sink) {
    sink.addHeaderInfo(7, Arg.indefiniteLength);
  }
}

@internal
mixin CborValueMixin implements CborValue {
  @override
  Object? toObject({
    bool parseDateTime = true,
    bool parseUri = true,
    bool decodeBase64 = false,
    bool allowMalformedUtf8 = false,
  }) =>
      toObjectInternal(
          {},
          ToObjectOptions(
            parseDateTime: parseDateTime,
            parseUri: parseUri,
            decodeBase64: decodeBase64,
            allowMalformedUtf8: allowMalformedUtf8,
          ));

  @override
  Object? toJson({Object? substituteValue, bool allowMalformedUtf8 = false}) =>
      toJsonInternal(
        {},
        ToJsonOptions(
          encoding: JsonBytesEncoding.base16,
          allowMalformedUtf8: allowMalformedUtf8,
          substituteValue: substituteValue,
        ),
      );

  JsonBytesEncoding? get expectedConversion {
    var retVal = JsonBytesEncoding.base16;
    for (final tag in tags.reversed) {
      switch (tag) {
        case CborTag.expectedConversionToBase16:
          retVal = JsonBytesEncoding.base16;
          break;
        case CborTag.expectedConversionToBase64:
          retVal = JsonBytesEncoding.base64;
          break;
        case CborTag.expectedConversionToBase64Url:
          retVal = JsonBytesEncoding.base64Url;
          break;
      }
    }
    return retVal;
  }
}
