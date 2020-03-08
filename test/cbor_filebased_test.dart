/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
@TestOn('vm')

import 'dart:io';
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;

void main() {
  // Common
  final inst = cbor.Cbor();
  final listener = cbor.ListenerDebug();
  final slistener = cbor.ListenerStack();

  group('File based decoding', () {
    test('Floats -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/floats.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], {
        'half': 0.0,
        'single': 3.4028234663852886e+38,
        'simple values': [true, false, null]
      });
    });

    test('Indefinitite string -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/indef_string.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.clearDecodeStack();
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], 'Helloworld!');
    });

    test('Integer -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/integer.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.clearDecodeStack();
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], 42);
    });

    test('Map -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/map.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.clearDecodeStack();
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], {'a key': false, 'a secret key': '42', 0: -1});
    });

    test('Nested array -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/nested_array.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.clearDecodeStack();
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], [
        1,
        2,
        [
          3,
          [4, 5, []]
        ]
      ]);
    });

    test('Tagged date -> ', () {
      // Decoding
      final currDir = Directory.current.path;
      final data = File('$currDir/test/data/tagged_date.cbor');
      final buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      inst.clearDecodeStack();
      inst.decodeFromBuffer(buff);
      final slist = inst.getDecodedData();
      expect(slist.length, 1);
      expect(slist[0], '2013-03-21T20:04:00Z');
      expect(inst.getDecodedHints()[0], cbor.dataHints.dateTimeString);
    });
  });
}
