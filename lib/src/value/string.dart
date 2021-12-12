/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:meta/meta.dart';

/// A CBOR string encoded in UTF-8.
class CborString implements CborValue {
  const CborString(this._string, [this.hints = const []]);

  final String _string;

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
  final Iterable<int> hints;
}

/// A CBOR string which encodes a datetime.
class CborDateTimeString extends CborString implements CborDateTime {
  CborDateTimeString(
    DateTime value, [
    Iterable<int> hints = const [CborHint.dateTimeString],
  ])  : _datetime = value,
        super(value.toIso8601String(), hints);

  CborDateTimeString.fromString(
    String str, [
    Iterable<int> hints = const [CborHint.dateTimeString],
  ]) : super(str, hints);

  DateTime? _datetime;

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
    String value, [
    Iterable<int> hints = const [CborHint.uri],
  ]) : super(value, hints);

  CborUri(
    Uri value, [
    Iterable<int> hints = const [CborHint.uri],
  ])  : _value = value,
        super(value.toString(), hints);

  Uri? _value;

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
    String value, [
    Iterable<int> hints = const [CborHint.base64],
  ]) : super(value, hints);

  CborBase64.encode(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64],
  ])  : _value = bytes,
        super(base64.encode(bytes), hints);

  List<int>? _value;

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
    String value, [
    Iterable<int> hints = const [CborHint.base64Url],
  ]) : super(value, hints);

  CborBase64Url.encode(
    List<int> bytes, [
    Iterable<int> hints = const [CborHint.base64Url],
  ])  : _value = bytes,
        super(base64Url.encode(bytes), hints);

  List<int>? _value;

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
    String data, [
    Iterable<int> hints = const [CborHint.regex],
  ]) : super(data, hints);
}

/// A CBOR string containing a regular expression.
///
/// Does not provide any additional functionality currently.
class CborMime extends CborString {
  CborMime.fromString(
    String data, [
    Iterable<int> hints = const [CborHint.mime],
  ]) : super(data, hints);
}
