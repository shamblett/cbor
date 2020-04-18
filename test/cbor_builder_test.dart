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
    test('List - Simple + Mixed Tag Values  -> ', () {
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
    test('List - Mixed tag + indefinte sequence -> ', () {
      final builder = cbor.ListBuilder.builder();
      builder.writeNull();
      final b64 = typed.Uint8Buffer();
      b64.addAll([1, 2, 3]);
      builder.writeBase64(b64);
      builder.writeBase16(b64);
      final b64Url = typed.Uint8Buffer();
      b64Url.addAll('a/url'.codeUnits);
      builder.writeBase64URL(b64Url);
      builder.startIndefinite(cbor.majorTypeString);
      builder.writeString('Indef String');
      builder.writeInt(23);
      builder.writeBreak();
      final builderRes = builder.getData();
      final inst = cbor.Cbor();
      final encoder = inst.encoder;
      encoder.addBuilderOutput(builderRes);
      inst.decodeFromInput();
      expect(inst.getDecodedData()[0], [
        null,
        [1, 2, 3],
        [1, 2, 3],
        [97, 47, 117, 114, 108],
        23
      ]);
      print(inst.decodedPrettyPrint(true));
    });
  });
  group('Map', () {
    test('Map - Simple + Mixed Tag Values  -> ', () {
      final builder = cbor.MapBuilder.builder();
      builder.writeInt(1);
      builder.writeDateTime('2020/04/20');
      builder.writeInt(2);
      builder.writeURI('a/uri/it/is');
      builder.writeInt(3);
      builder.writeArray([3, 4, 5]);
      final builderRes = builder.getData();
      final inst = cbor.Cbor();
      final encoder = inst.encoder;
      encoder.addBuilderOutput(builderRes);
      inst.decodeFromInput();
      print(inst.decodedPrettyPrint(true));
      expect(inst.getDecodedData()[0], {
        1: '2020/04/20',
        2: 'a/uri/it/is',
        3: [3, 4, 5]
      });
    });
  });
}
