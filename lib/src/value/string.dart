/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';
import '../utils/utils.dart';
import 'internal.dart';

/// A CBOR string encoded in UTF-8.
abstract class CborString extends CborValue {
  /// Returns the UTF-8 value of this.
  List<int> get utf8Bytes;

  CborLengthType get type;

  factory CborString(String string, {List<int> tags}) = _CborStringImpl;

  factory CborString.fromUtf8(List<int> value, {List<int> tags}) =
      _CborStringImpl.fromUtf8;

  factory CborString.indefinite(List<String> string, {List<int> tags}) =
      _CborIndefiniteLengthStringImpl;

  factory CborString.indefiniteFromUtf8(
    List<List<int>> value, {
    List<int> tags,
  }) = _CborIndefiniteLengthStringImpl.fromUtf8;

  /// Convert to [String].
  ///
  /// Throws [FormatException] if [allowMalformed] is false and the value
  /// is not valid UTF-8.
  @override
  String toString({bool allowMalformed = false});
}

class _CborStringImpl with CborValueMixin implements CborString {
  @override
  final List<int> tags;
  @override
  final CborLengthType type = CborLengthType.definite;

  String? _string;
  List<int>? _utf8;

  @override
  int get hashCode => Object.hashAll([utf8Bytes, tags].flattened);

  @override
  List<int> get utf8Bytes {
    _utf8 ??= utf8.encode(_string!);

    return _utf8!;
  }

  _CborStringImpl(this._string, {this.tags = const []});
  _CborStringImpl.fromUtf8(this._utf8, {this.tags = const []});

  @override
  String toString({bool allowMalformed = false}) {
    _string ??=
        allowMalformed
            ? const Utf8Decoder(allowMalformed: true).convert(_utf8!)
            : const Utf8Decoder(allowMalformed: false).convert(_utf8!);

    return _string!;
  }

  @override
  bool operator ==(Object other) =>
      other is CborString &&
      tags.equals(other.tags) &&
      utf8Bytes.equals(other.utf8Bytes);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return toString(allowMalformed: o.allowMalformedUtf8);
  }

  @override
  void encode(EncodeSink sink) {
    CborEncodeDefiniteLengthString(this).encode(sink);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return toString();
  }
}

class _CborIndefiniteLengthStringImpl
    with CborValueMixin
    implements CborString {
  @override
  final List<int> tags;
  @override
  final CborLengthType type = CborLengthType.indefinite;

  List<String>? _string;
  List<List<int>>? _utf8;

  @override
  int get hashCode => Object.hashAll([utf8Bytes, tags].flattened);

  @override
  List<int> get utf8Bytes {
    _utf8 ??= _string!.map(utf8.encode).toList(growable: false);

    return _utf8!.flattened.toList(growable: false);
  }

  _CborIndefiniteLengthStringImpl(this._string, {this.tags = const []});
  _CborIndefiniteLengthStringImpl.fromUtf8(this._utf8, {this.tags = const []});

  @override
  String toString({bool allowMalformed = false}) {
    _string ??= _utf8!
        .map(Utf8Decoder(allowMalformed: allowMalformed).convert)
        .toList(growable: false);

    return _string!.join();
  }

  @override
  bool operator ==(Object other) =>
      other is CborString &&
      tags.equals(other.tags) &&
      utf8Bytes.equals(other.utf8Bytes);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return toString(allowMalformed: o.allowMalformedUtf8);
  }

  @override
  void encode(EncodeSink sink) {
    _string ??= _utf8!
        .map(const Utf8Decoder(allowMalformed: true).convert)
        .toList(growable: false);

    CborEncodeIndefiniteLengthString(_string!).encode(sink);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return toString();
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length string.
///
/// This is never generated by decoder.
abstract class CborEncodeIndefiniteLengthString extends CborValue {
  factory CborEncodeIndefiniteLengthString(
    List<String> items, {
    List<int> tags,
  }) = _CborEncodeIndefiniteLengthStringImpl;
}

class _CborEncodeIndefiniteLengthStringImpl
    with CborValueMixin
    implements CborEncodeIndefiniteLengthString {
  final List<String> items;
  @override
  final List<int> tags;

  const _CborEncodeIndefiniteLengthStringImpl(
    this.items, {
    this.tags = const [],
  });

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return CborString(
      items.join(),
      tags: tags,
    ).toObjectInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(CborMajorType.textString, Arg.indefiniteLength);

    for (final value in items) {
      CborEncodeDefiniteLengthString(CborString(value)).encode(sink);
    }

    (const Break()).encode(sink);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return CborString(items.join(), tags: tags).toJsonInternal(cyclicCheck, o);
  }
}

/// Use this to force the [CborEncoder] to encode an definite length string.
///
/// This is never generated by decoder.
abstract class CborEncodeDefiniteLengthString extends CborValue {
  factory CborEncodeDefiniteLengthString(CborString input) =
      _CborEncodeDefiniteLengthStringImpl;
}

class _CborEncodeDefiniteLengthStringImpl
    with CborValueMixin
    implements CborEncodeDefiniteLengthString {
  final CborString inner;

  @override
  List<int> get tags => inner.tags;
  const _CborEncodeDefiniteLengthStringImpl(this.inner);

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return inner.toObjectInternal(cyclicCheck, o);
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return inner.toJsonInternal(cyclicCheck, o);
  }

  @override
  void encode(EncodeSink sink) {
    final bytes = utf8.encode(inner.toString());

    sink.addTags(tags);

    sink.addHeaderInfo(CborMajorType.textString, Arg.int(bytes.length));

    sink.add(bytes);
  }
}

/// A CBOR string which encodes a datetime.
abstract class CborDateTimeString extends CborString implements CborDateTime {
  /// Create a date time string.
  ///
  /// If [timeZoneOffset] is not provided, the timezone for [value] is used.
  ///
  /// This will ommit second fraction if zero, and trim it depending on the
  /// resolution.
  factory CborDateTimeString(
    DateTime value, {
    Duration? timeZoneOffset,
    List<int> tags,
  }) = _CborDateTimeStringImpl;

  factory CborDateTimeString.fromString(String str, {List<int> tags}) =
      _CborDateTimeStringImpl.fromString;

  factory CborDateTimeString.fromUtf8(List<int> str, {List<int> tags}) =
      _CborDateTimeStringImpl.fromUtf8;
}

class _CborDateTimeStringImpl extends _CborStringImpl
    implements CborDateTimeString {
  DateTime? _datetime;

  _CborDateTimeStringImpl(
    DateTime value, {
    Duration? timeZoneOffset,
    List<int> tags = const [CborTag.dateTimeString],
  }) : _datetime = value,
       super(value.toInternetIso8601String(timeZoneOffset), tags: tags);

  _CborDateTimeStringImpl.fromString(
    String super.str, {
    super.tags = const [CborTag.dateTimeString],
  });

  _CborDateTimeStringImpl.fromUtf8(
    List<int> super.str, {
    super.tags = const [CborTag.dateTimeString],
  }) : super.fromUtf8();

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return o.parseDateTime ? toDateTime() : toString();
  }

  @override
  DateTime toDateTime() {
    _datetime ??= DateTime.parse(toString());
    return _datetime!;
  }
}

/// A CBOR string containing URI.
abstract class CborUri extends CborString {
  factory CborUri.fromString(String value, {List<int> tags}) =
      _CborUriImpl.fromString;

  factory CborUri.fromUtf8(List<int> str, {List<int> tags}) =
      _CborUriImpl.fromUtf8;

  factory CborUri(Uri value, {List<int> tags}) = _CborUriImpl;

  /// Parse the URI, may throw [FormatException] if the URI is not valid.
  Uri parse();
}

class _CborUriImpl extends _CborStringImpl implements CborUri {
  Uri? _value;

  _CborUriImpl.fromString(
    String super.value, {
    super.tags = const [CborTag.uri],
  });

  _CborUriImpl(Uri value, {List<int> tags = const [CborTag.uri]})
    : _value = value,
      super(value.toString(), tags: tags);

  _CborUriImpl.fromUtf8(
    List<int> super.value, {
    super.tags = const [CborTag.uri],
  }) : super.fromUtf8();

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return o.parseUri ? parse() : toString();
  }

  @override
  Uri parse() {
    _value ??= Uri.parse(toString());
    return _value!;
  }
}

/// A CBOR string containing a base 64 value.
abstract class CborBase64 extends CborString {
  factory CborBase64.fromString(String value, {List<int> tags}) =
      _CborBase64Impl.fromString;

  factory CborBase64.encode(List<int> bytes, {List<int> tags}) =
      _CborBase64Impl.encode;

  factory CborBase64.fromUtf8(List<int> str, {List<int> tags}) =
      _CborBase64Impl.fromUtf8;

  List<int> decode();
}

class _CborBase64Impl extends _CborStringImpl implements CborBase64 {
  List<int>? _value;

  _CborBase64Impl.fromString(
    String super.value, {
    super.tags = const [CborTag.base64],
  });

  _CborBase64Impl.encode(
    List<int> bytes, {
    List<int> tags = const [CborTag.base64],
  }) : _value = bytes,
       super(base64.encode(bytes), tags: tags);

  _CborBase64Impl.fromUtf8(
    List<int> super.str, {
    super.tags = const [CborTag.base64],
  }) : super.fromUtf8();

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return o.decodeBase64 ? decode() : toString();
  }

  @override
  List<int> decode() {
    _value ??= base64.decode(base64.normalize(toString()));
    return _value!;
  }
}

/// A CBOR string containing a base 64 url safe value.
abstract class CborBase64Url extends CborString {
  factory CborBase64Url.fromString(String value, {List<int> tags}) =
      _CborBase64UrlImpl.fromString;

  factory CborBase64Url.encode(List<int> bytes, {List<int> tags}) =
      _CborBase64UrlImpl.encode;

  factory CborBase64Url.fromUtf8(List<int> str, {List<int> tags}) =
      _CborBase64UrlImpl.fromUtf8;

  /// Use [Base64Codec.urlSafe] to decode.
  List<int> decode();
}

class _CborBase64UrlImpl extends _CborStringImpl implements CborBase64Url {
  List<int>? _value;

  _CborBase64UrlImpl.fromString(
    String super.value, {
    super.tags = const [CborTag.base64Url],
  });

  _CborBase64UrlImpl.encode(
    List<int> bytes, {
    List<int> tags = const [CborTag.base64Url],
  }) : _value = bytes,
       super(base64Url.encode(bytes), tags: tags);

  _CborBase64UrlImpl.fromUtf8(
    List<int> super.str, {
    super.tags = const [CborTag.base64Url],
  }) : super.fromUtf8();

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return o.decodeBase64 ? decode() : toString();
  }

  @override
  List<int> decode() {
    _value ??= base64Url.decode(base64Url.normalize(toString()));
    return _value!;
  }
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
abstract class CborRegex extends CborString {
  factory CborRegex.fromString(String data, {List<int> tags}) =
      _CborRegexImpl.fromString;

  factory CborRegex.fromUtf8(List<int> str, {List<int> tags}) =
      _CborRegexImpl.fromUtf8;
}

class _CborRegexImpl extends _CborStringImpl implements CborRegex {
  _CborRegexImpl.fromString(
    String super.data, {
    super.tags = const [CborTag.regex],
  });

  _CborRegexImpl.fromUtf8(
    List<int> super.str, {
    super.tags = const [CborTag.regex],
  }) : super.fromUtf8();
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
abstract class CborMime extends CborString {
  factory CborMime.fromString(String data, {List<int> tags}) =
      _CborMimeImpl.fromString;

  factory CborMime.fromUtf8(List<int> str, {List<int> tags}) =
      _CborMimeImpl.fromUtf8;
}

class _CborMimeImpl extends _CborStringImpl implements CborMime {
  _CborMimeImpl.fromString(
    String super.data, {
    super.tags = const [CborTag.mime],
  });

  _CborMimeImpl.fromUtf8(
    List<int> super.str, {
    super.tags = const [CborTag.mime],
  }) : super.fromUtf8();
}
