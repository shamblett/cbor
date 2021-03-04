/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */
import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart';
import 'package:convert/convert.dart';
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
  test('Uint8List in array', () {
    final command = {};
    final data = Uint8List.fromList([196, 79, 51]);
    final inst = cbor.Cbor();
    final encoder = inst.encoder;
    expect(data, [196, 79, 51]);
    command['data'] = [data];
    encoder.writeMap(command);
    expect(inst.rawOutput.getData(),
        [161, 100, 100, 97, 116, 97, 129, 67, 196, 79, 51]);
  });
}
