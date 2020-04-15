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
    test('Simple + Mixed Tag Values  -> ', () {
      final builder = cbor.ListBuilder.builder();
      builder.writeInt(2);
      builder.writeDateTime('2020/04/20');
      builder.writeURI('a/uri/it/is');
      builder.writeArray([3, 4, 5]);
      builder.writeRegEx('^[12]');
      builder.writeDouble(4.0);
      builder.writeFloat(6.0);
      final builderRes = builder.getData();
      final inst = cbor.Cbor();
      final encoder = inst.encoder;
      encoder.addBuilderOutput(builderRes);
      encoder.writeFloat(3.0);
      encoder.writeMap({'a': 'avalue'});
      inst.decodeFromInput();
      print(inst.decodedPrettyPrint(true));
      expect(inst.getDecodedData(), [
        [
          2,
          '2020/04/20',
          'a/uri/it/is',
          [3, 4, 5],
          '^[12]',
          4.0,
          6.0
        ],
        3.0,
        {'a': 'avalue'}
      ]);
    });
    test('Simple + Nested built lists-> ', () {});
  });
}
