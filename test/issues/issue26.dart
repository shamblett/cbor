/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:typed_data/typed_data.dart';
import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  test('Decode', ()
  {
    final value = <int>[];
    final cbor = Cbor();
    final payloadBuffer = Uint8Buffer();
    payloadBuffer.addAll(value);
    cbor.decodeFromBuffer(payloadBuffer);
    cbor.getDecodedData();
  });
}
