/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

extension IterableExt<T> on Iterable<T> {
  Iterable<List<T>> chunks(int length) sync* {
    final iterator = this.iterator;

    while (true) {
      final chunk = <T>[];
      for (var i = 0; i < length; i++) {
        if (!iterator.moveNext()) {
          return;
        }

        chunk.add(iterator.current);
      }

      yield chunk;
    }
  }
}

extension SinkExt<T> on Sink<T> {
  Sink<U> map<U>(T Function(U) conversion) => _MapSink<T, U>(conversion, this);
}

class _MapSink<T, U> extends Sink<U> {
  _MapSink(this.map, this.sink);

  final T Function(U) map;
  final Sink<T> sink;

  @override
  void add(U data) {
    sink.add(map(data));
  }

  @override
  void close() {
    sink.close();
  }
}

/// Returns whether T is a subtype of U.
bool isSubtype<T, U>() => _Helper<T>() is _Helper<U>;

class _Helper<T> {
  const _Helper();
}

bool isHintSubtype(int hint) {
  switch (hint) {
    case CborTag.dateTimeString:
    case CborTag.epochDateTime:
    case CborTag.positiveBignum:
    case CborTag.negativeBignum:
    case CborTag.bigFloat:
    case CborTag.encodedCborData:
    case CborTag.uri:
    case CborTag.base64Url:
    case CborTag.base64:
    case CborTag.regex:
    case CborTag.mime:
      return true;
  }

  return false;
}

bool isExpectConversion(int tag) {
  switch (tag) {
    case CborTag.expectedConversionToBase16:
    case CborTag.expectedConversionToBase64:
    case CborTag.expectedConversionToBase64Url:
      return true;
  }

  return false;
}
