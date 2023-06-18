/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_buffers.dart';

import '../utils/arg.dart';

abstract class EncodeSink extends Sink<List<int>> {
  EncodeSink();

  final Set<Object> _references = {};

  factory EncodeSink.withBuffer(Uint8Buffer b) => _BufferEncodeSink(b);

  factory EncodeSink.withSink(Sink<List<int>> x) => _EncodeSink(x);

  void addToCycleCheck(Object object) {
    if (!_references.add(object)) {
      throw CborCyclicError(object);
    }
  }

  void removeFromCycleCheck(Object it) {
    _references.remove(it);
  }

  @override
  void close() {}

  void addTags(List<int> tags) {
    for (final value in tags) {
      addHeaderInfo(6, Arg.int(value));
    }
  }

  void addHeader(int majorType, int additionalInfo) {
    add([(majorType << 5) | additionalInfo]);
  }

  void addHeaderInfo(int majorType, Arg info) {
    if (info.isIndefiniteLength) {
      addHeader(majorType, 0x1f);
    } else if (info.isValidInt) {
      final int = info.toInt();

      if (int <= 23) {
        addHeader(majorType, info.toInt());
        return;
      } else if (int.bitLength <= 8) {
        addHeader(majorType, 24);
        add([int]);
      } else if (int.bitLength <= 16) {
        addHeader(majorType, 25);
        final x = Uint8List(2);
        ByteData.view(x.buffer).setUint16(0, info.toInt());
        add(x);
      } else if (int.bitLength <= 32) {
        addHeader(majorType, 26);
        final x = Uint8List(4);
        ByteData.view(x.buffer).setUint32(0, info.toInt());
        add(x);
      } else {
        addHeader(majorType, 27);
        add(u64BytesHelper(info.toInt()));      
      }
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



Uint8List u64BytesHelper(int x) {
  String rstr = x.toRadixString(2);
  while (rstr.length<64) {
    rstr = '0' + rstr;
  }
  List<int> bytes = [];
  for (int i=0;i<8;i++) {
    bytes.add(int.parse(rstr.substring(i*8, i*8+8), radix: 2));   
  }
  return Uint8List.fromList(bytes);
}

