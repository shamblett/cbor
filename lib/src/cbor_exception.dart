/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 09/03/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Exceptions
class CborException implements Exception {
  /// Construction
  CborException([this._message = 'No Message Supplied']);

  final String _message;
  static const String header = 'CborException: ';

  @override
  String toString() => '$header$_message';
}
