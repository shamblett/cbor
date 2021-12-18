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

@internal
class Break extends CborSimpleValue {
  const Break() : super(31);

  @override
  final List<int> tags = const [];

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    throw UnimplementedError();
  }

  /// <nodoc>
  @internal
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
  int? get expectedConversion {
    for (final tag in tags.reversed) {
      if (isExpectConversion(tag)) {
        return tag;
      }
    }
  }
}
