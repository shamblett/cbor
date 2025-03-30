/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_buffers.dart';
import 'package:characters/characters.dart';

import '../constants.dart';
import '../utils/arg.dart';

abstract class EncodeSink implements Sink<List<int>> {
  final Set<Object> _references = {};

  EncodeSink();

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
  void close() {
    return;
  }

  void addTags(List<int> tags) {
    for (final value in tags) {
      addHeaderInfo(CborMajorType.tag, Arg.int(value));
    }
  }

  void addHeader(int majorType, int additionalInfo) {
    add([(majorType << CborMajorType.map) | additionalInfo]);
  }

  void addHeaderInfo(int majorType, Arg info) {
    if (info.isIndefiniteLength) {
      addHeader(majorType, CborConstants.additionalInfoBitMask);
    } else if (info.isValidInt) {
      final int = info.toInt();

      if (int <= CborAdditionalInfo.simpleValueLow) {
        addHeader(majorType, info.toInt());
        return;
      } else if (int.bitLength <= CborConstants.byteLength) {
        addHeader(majorType, CborAdditionalInfo.simpleValueHigh);
        add([int]);
      } else if (int.bitLength <= CborConstants.sixteen) {
        addHeader(majorType, CborAdditionalInfo.halfPrecisionFloat);
        final x = Uint8List(CborConstants.two);
        ByteData.view(x.buffer).setUint16(0, info.toInt());
        add(x);
      } else if (int.bitLength <= CborConstants.bitsPerWord) {
        addHeader(majorType, CborAdditionalInfo.singlePrecisionFloat);
        final x = Uint8List(CborConstants.bytesPerWord);
        ByteData.view(x.buffer).setUint32(0, info.toInt());
        add(x);
      } else {
        addHeader(majorType, CborAdditionalInfo.doublePrecisionFloat);
        add(u64BytesHelper(info.toInt()));
      }
    } else {
      addHeader(majorType, CborAdditionalInfo.doublePrecisionFloat);
      final x = Uint8List(CborConstants.byteLength);
      final infoBigInt = info.toBigInt();
      ByteData.view(x.buffer).setUint32(
        0,
        (infoBigInt >> CborConstants.bitsPerWord)
            .toUnsigned(CborConstants.bitsPerWord)
            .toInt(),
      );
      ByteData.view(x.buffer).setUint32(
        CborConstants.bytesPerWord,
        infoBigInt.toUnsigned(CborConstants.bitsPerWord).toInt(),
      );
      add(x);
    }
  }
}

class _BufferEncodeSink extends EncodeSink {
  final Uint8Buffer buffer;

  _BufferEncodeSink(this.buffer);

  @override
  void add(List<int> data) {
    buffer.addAll(data);
  }
}

class _EncodeSink extends EncodeSink {
  final Sink<List<int>> _sink;

  _EncodeSink(this._sink);

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
  String rstr = x.toRadixString(CborConstants.binRadix);
  while (rstr.length < CborConstants.bitsPerDoubleWord) {
    rstr = '0$rstr';
  }
  List<int> bytes = [];
  for (int i = 0; i < CborConstants.byteLength; i++) {
    bytes.add(
      int.parse(
        '${rstr.characters.getRange(i * CborConstants.byteLength, i * CborConstants.byteLength + CborConstants.byteLength)}',
        radix: CborConstants.binRadix,
      ),
    );
  }
  return Uint8List.fromList(bytes);
}
