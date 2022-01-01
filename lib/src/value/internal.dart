/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

// This is for internal usage and should not be returned to the user

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import '../utils/utils.dart';

class ToObjectOptions {
  ToObjectOptions({
    required this.parseDateTime,
    required this.parseUri,
    required this.decodeBase64,
  });

  final bool parseDateTime;
  final bool parseUri;
  final bool decodeBase64;
}

class ToJsonOptions {
  ToJsonOptions({
    required this.encoding,
    this.substituteValue,
  });

  ToJsonOptions copyWith({
    JsonBytesEncoding? encoding,
  }) =>
      ToJsonOptions(
        encoding: encoding ?? this.encoding,
        substituteValue: substituteValue,
      );

  final JsonBytesEncoding encoding;
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
    sink.addHeaderInfo(7, Info.indefiniteLength);
  }
}

@internal
mixin CborValueMixin implements CborValue {
  @override
  Object? toObject({
    bool parseDateTime = true,
    bool parseUri = true,
    bool decodeBase64 = false,
  }) =>
      toObjectInternal(
          {},
          ToObjectOptions(
            parseDateTime: parseDateTime,
            parseUri: parseUri,
            decodeBase64: decodeBase64,
          ));

  @override
  Object? toJson({Object? substituteValue}) => toJsonInternal(
        {},
        ToJsonOptions(
          encoding: JsonBytesEncoding.base64Url,
          substituteValue: substituteValue,
        ),
      );

  JsonBytesEncoding? get expectedConversion {
    for (final tag in tags.reversed) {
      switch (tag) {
        case CborTag.expectedConversionToBase16:
          return JsonBytesEncoding.base16;
        case CborTag.expectedConversionToBase64:
          return JsonBytesEncoding.base64;
        case CborTag.expectedConversionToBase64Url:
          return JsonBytesEncoding.base64Url;
      }
    }
  }
}
