/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'dart:io';

void main() {
  // Common
  final cbor.ListenerDebug listener = new cbor.ListenerDebug();
  final cbor.ListenerStack slistener = new cbor.ListenerStack();

  group('Original C++ tests', () {
    test('Encode/Decode confidence -> ', () {
      // Encoding
      final cbor.OutputStandard output = new cbor.OutputStandard();
      final cbor.Encoder encoder = new cbor.Encoder(output);
      encoder.writeArray([9]);
      encoder.writeInt(123);
      encoder.writeInt(-457);
      encoder.writeString("barrr");
      encoder.writeInt(321);
      encoder.writeInt(322);
      encoder.writeString("foo");
      encoder.writeBool(true);
      encoder.writeBool(false);
      encoder.writeNull();
      encoder.writeUndefined();

      // Decoding
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      listener.banner('>>> Original C++ tests - Encode/Decode confidence');
      decoder.run();
    });
  });

  group('Known patterns', () {
    test('Pattern 1  -> ', () {
      // Encoding
      final cbor.OutputStandard output = new cbor.OutputStandard();
      final cbor.Encoder encoder = new cbor.Encoder(output);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll([0x31, 0x32, 0x55]);
      output.pause();
      encoder.writeBytes(data);
      final typed.Uint8Buffer dVal = output.getData();
      output.restart();
      final bool res = encoder.writeMap({
        "p16": 16,
        "uni": "\u901A\u8A0A\u9023\u63A5\u57E0 (COM1)",
        "n1": -1,
        "ascii": "hello",
        "nil": null,
        "empty_arr": [],
        "p65535": 65535,
        "bin": dVal,
        "n2G": -2147483648,
        "p1": 1,
        "n65535": -65535,
        "n16": -16,
        "zero": 0,
        "arr": [1, 2, 3],
        "obj": {"foo": "bar"},
        "bfalse": false,
        "p255": 255,
        "p2G": 2147483648,
        "n255": -255,
        "btrue": true
      });
      expect(res, isTrue);
      final List<int> val = output.getDataAsList();
      expect(val, [
        0xB4,
        0x63,
        0x70,
        0x31,
        0x36,
        0x10,
        0x63,
        0x75,
        0x6E,
        0x69,
        0x76,
        0xE9,
        0x80,
        0x9A,
        0xE8,
        0xA8,
        0x8A,
        0xE9,
        0x80,
        0xA3,
        0xE6,
        0x8E,
        0xA5,
        0xE5,
        0x9F,
        0xA0,
        0x20,
        0x28,
        0x43,
        0x4F,
        0x4D,
        0x31,
        0x29,
        0x62,
        0x6E,
        0x31,
        0x20,
        0x65,
        0x61,
        0x73,
        0x63,
        0x69,
        0x69,
        0x65,
        0x68,
        0x65,
        0x6C,
        0x6C,
        0x6F,
        0x63,
        0x6E,
        0x69,
        0x6C,
        0xF6,
        0x69,
        0x65,
        0x6D,
        0x70,
        0x74,
        0x79,
        0x5F,
        0x61,
        0x72,
        0x72,
        0x80,
        0x66,
        0x70,
        0x36,
        0x35,
        0x35,
        0x33,
        0x35,
        0x19,
        0xFF,
        0xFF,
        0x63,
        0x62,
        0x69,
        0x6E,
        0x43,
        0x31,
        0x32,
        0x55,
        0x63,
        0x6E,
        0x32,
        0x47,
        0x3A,
        0x7F,
        0xFF,
        0xFF,
        0xFF,
        0x62,
        0x70,
        0x31,
        0x01,
        0x66,
        0x6E,
        0x36,
        0x35,
        0x35,
        0x33,
        0x35,
        0x39,
        0xFF,
        0xFE,
        0x63,
        0x6E,
        0x31,
        0x36,
        0x2F,
        0x64,
        0x7A,
        0x65,
        0x72,
        0x6F,
        0x00,
        0x63,
        0x61,
        0x72,
        0x72,
        0x83,
        0x01,
        0x02,
        0x03,
        0x63,
        0x6F,
        0x62,
        0x6A,
        0xA1,
        0x63,
        0x66,
        0x6F,
        0x6F,
        0x63,
        0x62,
        0x61,
        0x72,
        0x66,
        0x62,
        0x66,
        0x61,
        0x6C,
        0x73,
        0x65,
        0xF4,
        0x64,
        0x70,
        0x32,
        0x35,
        0x35,
        0x18,
        0xFF,
        0x63,
        0x70,
        0x32,
        0x47,
        0x1A,
        0x80,
        0x00,
        0x00,
        0x00,
        0x64,
        0x6E,
        0x32,
        0x35,
        0x35,
        0x38,
        0xFE,
        0x65,
        0x62,
        0x74,
        0x72,
        0x75,
        0x65,
        0xF5
      ]);
    });
  });

  group('File based decoding', () {
    test('Floats -> ', () {
      // Decoding
      final String currDir = Directory.current.path;
      final File data = new File(currDir + '/test/data/floats.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - floats');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
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
      final File data = new File(currDir + '/test/data/indef_string.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - Indefinitite string');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
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
      final File data = new File(currDir + '/test/data/integer.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - Integer');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
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
      final File data = new File(currDir + '/test/data/map.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - Map');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
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
      final File data = new File(currDir + '/test/data/nested_array.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - Nested array');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
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
      final File data = new File(currDir + '/test/data/tagged_date.cbor');
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data.readAsBytesSync());
      final cbor.Input input = new cbor.Input(buff, data.lengthSync());
      listener.banner('>>> File based decoding - Tagged date');
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      decoder.setListener(slistener);
      slistener.stack.clear();
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "2013-03-21T20:04:00Z");
      slistener.stack
          .peek()
          .hint == cbor.dataHints.dateTimeString;
    });
  });
}
