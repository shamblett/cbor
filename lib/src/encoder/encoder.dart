import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_buffers.dart';

import 'sink.dart';

class CborEncoder extends Converter<CborValue, List<int>> {
  const CborEncoder();

  @override
  List<int> convert(CborValue input) {
    final b = Uint8Buffer();
    input.encode(EncodeSink.withBuffer(b));
    return b;
  }

  @override
  Sink<CborValue> startChunkedConversion(Sink<List<int>> sink) {
    return _ChunkedConversion(EncodeSink.withSink(sink));
  }
}

class _ChunkedConversion extends Sink<CborValue> {
  _ChunkedConversion(this.sink);

  final EncodeSink sink;

  @override
  void add(CborValue data) {
    data.encode(sink);
  }

  @override
  void close() {
    sink.close();
  }
}
