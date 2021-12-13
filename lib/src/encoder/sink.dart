import 'dart:typed_data';

import 'package:typed_data/typed_buffers.dart';

import '../utils/info.dart';

abstract class EncodeSink extends Sink<List<int>> {
  EncodeSink();

  factory EncodeSink.withBuffer(Uint8Buffer b) => _BufferEncodeSink(b);

  factory EncodeSink.withSink(Sink<List<int>> x) => _EncodeSink(x);

  @override
  void close() {}

  void addTags(List<int> tags) {
    for (final value in tags) {
      addHeaderInfo(6, Info.int(value));
    }
  }

  void addHeader(int majorType, int additionalInfo) {
    add([(majorType << 5) | additionalInfo]);
  }

  void addHeaderInfo(int majorType, Info info) {
    if (info.isIndefiniteLength) {
      addHeader(majorType, 0x1f);
    } else if (info.bitLength <= 8) {
      if (info.toInt() <= 23) {
        addHeader(majorType, info.toInt());
        return;
      }

      addHeader(majorType, 24);
      add([info.toInt()]);
    } else if (info.bitLength <= 16) {
      addHeader(majorType, 25);
      final x = Uint8List(2);
      ByteData.view(x.buffer).setUint16(0, info.toInt());
      add(x);
    } else if (info.bitLength <= 32) {
      addHeader(majorType, 26);
      final x = Uint8List(4);
      ByteData.view(x.buffer).setUint32(0, info.toInt());
      add(x);
    } else {
      addHeader(majorType, 27);
      final x = Uint8List(8);
      final infoBigInt = info.toBigInt();
      ByteData.view(x.buffer)
          .setUint32(0, (infoBigInt >> 32).toUnsigned(32).toInt());
      ByteData.view(x.buffer).setUint32(4, infoBigInt.toUnsigned(32).toInt());
      add(x);
    }
  }
}

class _BufferEncodeSink extends EncodeSink {
  _BufferEncodeSink(this.buffer);

  final Uint8Buffer buffer;

  @override
  void add(List<int> data) {
    buffer.addAll(data);
  }
}

class _EncodeSink extends EncodeSink {
  _EncodeSink(this._sink);

  final Sink<List<int>> _sink;

  @override
  void close() {
    _sink.close();
  }

  @override
  void add(List<int> data) {
    _sink.add(data);
  }
}
