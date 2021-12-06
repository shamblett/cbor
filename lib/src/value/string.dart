/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';

/// A CBOR string encoded in UTF-8.
class CborString implements CborValue {
  const CborString(this._string, [this.hints = const []]);

  CborString.fromUtf8(List<int> bytes, [this.hints = const []])
      : _string = (const Utf8Codec(allowMalformed: true)).decode(bytes);

  final String _string;

  @override
  String toString() => _string;
  @override
  bool operator ==(Object other) =>
      other is CborString && _string == other._string;
  @override
  int get hashCode => null.hashCode;
  @override
  final Iterable<int> hints;
}

/// A CBOR string which encodes a datetime.
class CborDateTimeString extends CborString implements CborDateTime {
  CborDateTimeString(
    DateTime datetime, [
    Iterable<int> hints = const [CborHint.dateTimeString],
  ]) : super(datetime.toIso8601String(), hints);

  CborDateTimeString.fromUtf8(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.dateTimeString],
  ]) : super.fromUtf8(bytes, hints);

  const CborDateTimeString.fromString(
    String str, [
    Iterable<int> hints = const [CborHint.dateTimeString],
  ]) : super(str, hints);

  @override
  DateTime toDateTime() => DateTime.parse(toString());
}

/// A CBOR string containing URI.
class CborUri extends CborString {
  CborUri.fromUtf8(
    List<int> data, [
    Iterable<int> hints = const [CborHint.uri],
  ]) : super.fromUtf8(data, hints);

  const CborUri.fromString(
    String value, [
    Iterable<int> hints = const [CborHint.uri],
  ]) : super(value, hints);

  CborUri(
    Uri value, [
    Iterable<int> hints = const [CborHint.uri],
  ]) : super(value.toString(), hints);

  /// Parse the URI, may throw [FormatException] if the URI is not valid.
  Uri parse() => Uri.parse(toString());
}

/// A CBOR string containing a base 64 value.
class CborBase64 extends CborString {
  CborBase64.fromUtf8(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64],
  ]) : super.fromUtf8(bytes, hints);

  const CborBase64.fromString(
    String value, [
    Iterable<int> hints = const [CborHint.base64],
  ]) : super(value, hints);

  CborBase64.encode(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64],
  ]) : super(base64.encode(bytes), hints);

  /// Use [Base64Codec] to decode.
  List<int> decode() {
    return base64.decode(toString());
  }
}

/// A CBOR string containing a base 64 url safe value.
class CborBase64Url extends CborString {
  CborBase64Url.fromUtf8(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64Url],
  ]) : super.fromUtf8(bytes, hints);

  const CborBase64Url.fromString(
    String value, [
    Iterable<int> hints = const [CborHint.base64Url],
  ]) : super(value, hints);

  CborBase64Url.encode(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64Url],
  ]) : super(base64Url.encode(bytes), hints);

  /// Use [Base64Codec.urlSafe] to decode.
  List<int> decode() {
    return base64Url.decode(toString());
  }
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
class CborRegex extends CborString {
  CborRegex.fromUtf8(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.regex],
  ]) : super.fromUtf8(bytes, hints);

  CborRegex(
    String data, [
    Iterable<int> hints = const [CborHint.regex],
  ]) : super(data, hints);
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
class CborMime extends CborString {
  CborMime.fromUtf8(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.regex],
  ]) : super.fromUtf8(bytes, hints);

  CborMime(
    String data, [
    Iterable<int> hints = const [CborHint.regex],
  ]) : super(data, hints);
}
