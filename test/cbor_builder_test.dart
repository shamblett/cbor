/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;

void main() {
  group('List', () {
    test('Mixed tag values  -> ', () {
      final builder = cbor.ListBuilder.builder();
      builder.writeDateTime('2020/04/20');
      builder.writeURI('a/uri/it/is');
      builder.writeRegEx('^[12]');
      final builderRes = builder.getData();
      final inst = cbor.Cbor();
      final encoder = inst.encoder;
      encoder.writeRawBuffer(builderRes);
      inst.decodeFromInput();
      print(inst.decodedPrettyPrint(true));
    });
  });
}
