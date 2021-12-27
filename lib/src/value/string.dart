/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'internal.dart';

/// A CBOR string encoded in UTF-8.
class CborString with CborValueMixin implements CborValue {
  const CborString(this._string, {this.tags = const []});

  final String _string;

  /// <nodoc>
  @internal
  void verify() {}

  @override
  String toString() => _string;
  @override
  bool operator ==(Object other) =>
      other is CborString && _string == other._string;
  @override
  int get hashCode => null.hashCode;
  @override
  final List<int> tags;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return toString();
  }

  /// <nodoc>
  @internal
  @override
  void encode(EncodeSink sink) {
    CborEncodeDefiniteLengthString(this).encode(sink);
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length string.
///
/// This is never generated by decoder.
class CborEncodeIndefiniteLengthString
    with CborValueMixin
    implements CborValue {
  CborEncodeIndefiniteLengthString(this.items, {this.tags = const []});

  final List<String> items;
  @override
  final List<int> tags;

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
    sink.addTags(tags);

    sink.addHeaderInfo(3, Info.indefiniteLength);

    for (final value in items) {
      CborEncodeDefiniteLengthString(CborString(value)).encode(sink);
    }

    (const Break()).encode(sink);
  }
}

/// Use this to force the [CborEncoder] to encode an definite length string.
///
/// This is never generated by decoder.
class CborEncodeDefiniteLengthString with CborValueMixin implements CborValue {
  const CborEncodeDefiniteLengthString(this.inner);

  final CborString inner;

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
    final bytes = utf8.encode(inner._string);

    sink.addTags(tags);

    sink.addHeaderInfo(3, Info.int(bytes.length));

    sink.add(bytes);
  }

  @override
  List<int> get tags => inner.tags;

  @override
  int? get expectedConversion => inner.expectedConversion;
}

/// A CBOR string which encodes a datetime.
class CborDateTimeString extends CborString implements CborDateTime {
  CborDateTimeString(
    DateTime value, {
    List<int> tags = const [CborTag.dateTimeString],
  })  : _datetime = value,
        super(value.toIso8601String(), tags: tags);

  CborDateTimeString.fromString(
    String str, {
    List<int> tags = const [CborTag.dateTimeString],
  }) : super(str, tags: tags);

  DateTime? _datetime;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.parseDateTime) {
      return toDateTime();
    } else {
      return toString();
    }
  }

  /// <nodoc>
  @internal
  @override
  void verify() {
    _datetime ??= DateTime.parse(toString());
  }

  @override
  DateTime toDateTime() {
    verify();
    return _datetime!;
  }
}

/// A CBOR string containing URI.
class CborUri extends CborString {
  CborUri.fromString(
    String value, {
    List<int> tags = const [CborTag.uri],
  }) : super(value, tags: tags);

  CborUri(
    Uri value, {
    List<int> tags = const [CborTag.uri],
  })  : _value = value,
        super(value.toString(), tags: tags);

  Uri? _value;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.parseUri) {
      return parse();
    } else {
      return toString();
    }
  }

  /// <nodoc>
  @internal
  @override
  void verify() {
    _value ??= Uri.parse(toString());
  }

  /// Parse the URI, may throw [FormatException] if the URI is not valid.
  Uri parse() {
    verify();
    return _value!;
  }
}

/// A CBOR string containing a base 64 value.
class CborBase64 extends CborString {
  CborBase64.fromString(
    String value, {
    List<int> tags = const [CborTag.base64],
  }) : super(value, tags: tags);

  CborBase64.encode(
    List<int> bytes, {
    List<int> tags = const [CborTag.base64],
  })  : _value = bytes,
        super(base64.encode(bytes), tags: tags);

  List<int>? _value;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.decodeBase64) {
      return decode();
    } else {
      return toString();
    }
  }

  /// <nodoc>
  @internal
  @override
  void verify() {
    _value ??= base64.decode(toString());
  }

  /// Use [Base64Codec] to decode.
  List<int> decode() {
    verify();
    return _value!;
  }
}

/// A CBOR string containing a base 64 url safe value.
class CborBase64Url extends CborString {
  CborBase64Url.fromString(
    String value, {
    List<int> tags = const [CborTag.base64Url],
  }) : super(value, tags: tags);

  CborBase64Url.encode(
    List<int> bytes, {
    List<int> tags = const [CborTag.base64Url],
  })  : _value = bytes,
        super(base64Url.encode(bytes), tags: tags);

  List<int>? _value;

  /// <nodoc>
  @internal
  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    if (o.decodeBase64) {
      return decode();
    } else {
      return toString();
    }
  }

  /// <nodoc>
  @internal
  @override
  void verify() {
    _value ??= base64Url.decode(toString());
  }

  /// Use [Base64Codec.urlSafe] to decode.
  List<int> decode() {
    verify();
    return _value!;
  }
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
class CborRegex extends CborString {
  CborRegex.fromString(
    String data, {
    List<int> tags = const [CborTag.regex],
  }) : super(data, tags: tags);
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
class CborMime extends CborString {
  CborMime.fromString(
    String data, {
    List<int> tags = const [CborTag.mime],
  }) : super(data, tags: tags);
}