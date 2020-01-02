/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
@TestOn("vm")

import 'dart:io';
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;

// ignore_for_file: prefer_single_quotes
// ignore_for_file: always_specify_types
// ignore_for_file: prefer_final_fields
// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

void main() {
  // Common
  final cbor.ListenerDebug listener = cbor.ListenerDebug();
  final cbor.ListenerStack slistener = cbor.ListenerStack();

  group('File based decoding', () {
    test('Floats -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/floats.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - floats');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], {
        "half": 0.0,
        "single": 3.4028234663852886e+38,
        "simple values": [true, false, null]
      });
    });

    test('Indefinitite string -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/indef_string.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - Indefinitite string');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "Helloworld!");
    });

    test('Integer -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/integer.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - Integer');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 42);
    });

    test('Map -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/map.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - Map');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], {"a key": false, "a secret key": "42", 0: -1});
    });

    test('Nested array -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/nested_array.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - Nested array');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
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
      final String currDir = Directory.current.path;
      final File data = File('$currDir/test/data/tagged_date.cbor');
      final typed.Uint8Buffer buff = typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = cbor.Input(buff);
      listener.banner('>>> File based decoding - Tagged date');
      final cbor.Decoder decoder = cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.listener = slistener;
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "2013-03-21T20:04:00Z");
      expect(slistener.stack.peek().hint, cbor.dataHints.dateTimeString);
    });
  });
}
