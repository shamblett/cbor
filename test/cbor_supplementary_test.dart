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
  final cbor.OutputStandard output = new cbor.OutputStandard();

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

  group('Error handling', () {
    test('No input -> ', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.stack.hasErrors(), false);
      final List<String> errors = slistener.stack.errors();
      expect(errors, isNull);
    });

    test('Random bytes -> ', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [0xcd, 0xfe, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.stack.hasErrors(), true);
      final List<String> errors = slistener.stack.errors();
      expect(errors[0], "Decoder::invalid special type");
    });

    test('Premature termination -> ', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [0x44, 0x01, 0x02, 0x03];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.stack.hasErrors(), false);
      final List<String> errors = slistener.stack.errors();
      expect(errors, isNull);
    });
  });

  group('Extra tags', () {
    test('Tag (33) Base64 URL', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [
        0xd8,
        0x21,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "http://www.example.com");
      final cbor.DartItem item = slistener.stack.peek();
      expect(item.hint, cbor.dataHints.base64Url);
    });

    test('Tag (34) Base64 String', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [
        0xd8,
        0x22,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "http://www.example.com");
      final cbor.DartItem item = slistener.stack.peek();
      expect(item.hint, cbor.dataHints.base64);
    });

    test('Tag (35) RegExp', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [
        0xd8,
        0x23,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "http://www.example.com");
      final cbor.DartItem item = slistener.stack.peek();
      expect(item.hint, cbor.dataHints.regex);
    });

    test('Tag (36) MIME', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [
        0xd8,
        0x24,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "http://www.example.com");
      final cbor.DartItem item = slistener.stack.peek();
      expect(item.hint, cbor.dataHints.mime);
    });

    test('Tag (55799) Self Describe CBOR', () {
      output.clear();
      slistener.stack.clear();
      final List<int> values = [
        0xd9,
        0xd9,
        0xf7,
        0x45,
        0x64,
        0x49,
        0x45,
        0x54,
        0x46
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], [0x64, 0x49, 0x45, 0x54, 0x46]);
      final cbor.DartItem item = slistener.stack.peek();
      expect(item.hint, cbor.dataHints.selfDescCBOR);
    });
  });

  group('Dog Food', () {

    test('Encode/Decode confidence -> ', () {
      // Encoding
      cbor.init();
      final cbor.OutputStandard output = new cbor.OutputStandard();
      final cbor.Encoder encoder = new cbor.Encoder(output);
      encoder.writeArray([9, 10, 11]);
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
      encoder.writeMap({
        "a": [1, 2, 3],
        2: true,
        3: "Hello"
      });
      encoder.writeSingle(36.908);
      encoder.writeDouble(35.66e4);
      encoder.writeHalf(20.0);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll([01, 02, 03, 89]);
      encoder.writeBytes(data);
      encoder.writeDateTime("2013-03-21T20:04:00Z");
      //encoder.writeEpoch(1234567);

      // Decoding
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, slistener);
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 17);
      expect(slist[0], [9, 10, 11]);
      expect(slist[1], 123);
      expect(slist[2], -457);
      expect(slist[3], "barrr");
      expect(slist[4], 321);
      expect(slist[5], 322);
      expect(slist[6], "foo");
      expect(slist[7], isTrue);
      expect(slist[8], isFalse);
      expect(slist[9], isNull);
      expect(slist[10], isNull);
      expect(slist[11], {
        "a": [1, 2, 3],
        2: true,
        3: "Hello"
      });
      expect(slist[12], greaterThanOrEqualTo(36.908));
      expect(slist[13], 35.66e4);
      expect(slist[14], 20.0);
      expect(slist[15], [01, 02, 03, 89]);
      expect(slist[16], "2013-03-21T20:04:00Z");
      //expect(slist[17], 1234567);
    });
  });
}
