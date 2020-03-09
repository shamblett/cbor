/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:convert/convert.dart';

import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;

void main() {
  // Common
  final slistener = cbor.ListenerStack();
  final output = cbor.OutputStandard();

  group('Known patterns', () {
    test('Pattern 1  -> ', () {
      // Encoding
      final output = cbor.OutputStandard();
      final encoder = cbor.Encoder(output);
      final data = typed.Uint8Buffer();
      data.addAll([0x31, 0x32, 0x55]);
      output.pause();
      encoder.writeBytes(data);
      final dVal = output.getData();
      output.restart();
      final res = encoder.writeMap({
        'p16': 16,
        'uni': '\u901A\u8A0A\u9023\u63A5\u57E0 (COM1)',
        'n1': -1,
        'ascii': 'hello',
        'nil': null,
        'empty_arr': [],
        'p65535': 65535,
        'bin': dVal,
        'n2G': -2147483648,
        'p1': 1,
        'n65535': -65535,
        'n16': -16,
        'zero': 0,
        'arr': [1, 2, 3],
        'obj': {'foo': 'bar'},
        'bfalse': false,
        'p255': 255,
        'p2G': 2147483648,
        'n255': -255,
        'btrue': true
      });
      expect(res, isTrue);
      final val = output.getDataAsList();
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

  group('Error handling', () {
    test('No input -> ', () {
      output.clear();
      slistener.itemStack.clear();
      final values = <int>[];
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.itemStack.hasErrors(), false);
      final errors = slistener.itemStack.errors();
      expect(errors, isNull);
    });

    test('Random bytes -> ', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [0xcd, 0xfe, 0x00];
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.itemStack.hasErrors(), true);
      final errors = slistener.itemStack.errors();
      expect(errors[0], 'Decoder::invalid special type');
    });

    test('Premature termination -> ', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [0x44, 0x01, 0x02, 0x03];
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      expect(slistener.itemStack.hasErrors(), false);
      final errors = slistener.itemStack.errors();
      expect(errors, isNull);
    });
  });

  group('Extra tags', () {
    test('Tag (33) Base64 URL', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [
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
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final slist = slistener.itemStack.walk();
      expect(slist.length, 1);
      expect(slist[0].data, 'http://www.example.com');
    });

    test('Tag (34) Base64 String', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [
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
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final slist = slistener.itemStack.walk();
      expect(slist.length, 1);
      expect(slist[0].data, 'http://www.example.com');
    });

    test('Tag (35) RegExp', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [
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
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final slist = slistener.itemStack.walk();
      expect(slist.length, 1);
      expect(slist[0].data, 'http://www.example.com');
    });

    test('Tag (36) MIME', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [
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
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final slist = slistener.itemStack.walk();
      expect(slist.length, 1);
      expect(slist[0].data, 'http://www.example.com');
    });

    test('Tag (55799) Self Describe CBOR', () {
      output.clear();
      slistener.itemStack.clear();
      final values = [0xd9, 0xd9, 0xf7, 0x45, 0x64, 0x49, 0x45, 0x54, 0x46];
      final buffer = typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final input = cbor.Input(output.getData());
      final decoder = cbor.Decoder.withListener(input, slistener);
      decoder.run();
      final slist = slistener.itemStack.walk();
      expect(slist.length, 1);
      expect(slist[0].data, [0x64, 0x49, 0x45, 0x54, 0x46]);
    });
  });

  group('Dog Food', () {
    test('Encode/Decode confidence -> ', () {
      var inst = cbor.Cbor();
      // Encoding
      final encoder = inst.encoder;
      encoder.writeArray([9, 10, 11]);
      encoder.writeInt(123);
      encoder.writeInt(-457);
      encoder.writeString('barrr');
      encoder.writeInt(321);
      encoder.writeInt(322);
      encoder.writeString('foo');
      encoder.writeBool(true);
      encoder.writeBool(false);
      encoder.writeNull();
      encoder.writeUndefined();
      encoder.writeMap({
        'a': [1, 2, 3],
        2: true,
        3: 'Hello'
      });
      encoder.writeSingle(36.908);
      encoder.writeDouble(35.66e4);
      encoder.writeHalf(20.0);
      encoder.writeDateTime('2013-03-21T20:04:00Z');
      encoder.writeEpoch(1234567);
      encoder.writeSimple(10);
      final data = typed.Uint8Buffer();
      data.addAll([01, 02, 03, 89]);
      encoder.writeBytes(data);
      data[3] = 90;
      encoder.writeBase64(data);
      data[3] = 91;
      encoder.writeCborDi(data);
      data[3] = 92;
      encoder.writeBase64URL(data);
      data[3] = 93;
      encoder.writeBase16(data);
      encoder.writeURI('example.com');
      encoder.writeFloat(19876.66);
      encoder.writeSpecial(6);
      encoder.writeString('Strea', true);
      encoder.writeString('ming');
      encoder.writeBreak();
      data[3] = 94;
      encoder.writeBuff(data, true);
      data[3] = 95;
      encoder.writeBuff(data);
      encoder.writeBreak();
      encoder.writeArray([6, 7, 8], true);
      encoder.writeArray([9, 10, 11]);
      encoder.writeBreak();
      encoder.writeMap({'1': 'First', '2': 'Second'}, true);
      encoder.writeMap({'3': 'Third'});
      encoder.writeBreak();

      // Decoding
      inst.decodeFromInput();
      var slist = inst.getDecodedData();
      expect(slist, isNotNull);
      expect(slist.length, 30);
      expect(slist[0], [9, 10, 11]);
      expect(slist[1], 123);
      expect(slist[2], -457);
      expect(slist[3], 'barrr');
      expect(slist[4], 321);
      expect(slist[5], 322);
      expect(slist[6], 'foo');
      expect(slist[7], isTrue);
      expect(slist[8], isFalse);
      expect(slist[9], isNull);
      expect(slist[10], isNull);
      expect(slist[11], {
        'a': [1, 2, 3],
        2: true,
        3: 'Hello'
      });
      expect(slist[12], greaterThanOrEqualTo(36.908));
      expect(slist[13], 35.66e4);
      expect(slist[14], 20.0);
      expect(slist[15], '2013-03-21T20:04:00Z');
      expect(slist[16], 1234567);
      expect(slist[17], 10);
      expect(slist[18], [01, 02, 03, 89]);
      expect(slist[19], [01, 02, 03, 90]);
      expect(slist[20], [01, 02, 03, 91]);
      expect(slist[21], [01, 02, 03, 92]);
      expect(slist[22], [01, 02, 03, 93]);
      expect(slist[23], 'example.com');
      expect(slist[24], greaterThanOrEqualTo(19876.66));
      expect(slist[25], 6);
      expect(slist[26], 'Streaming');
      expect(slist[27], [01, 02, 03, 94, 01, 02, 03, 95]);
      expect(slist[28], [
        06,
        07,
        08,
        [09, 10, 11]
      ]);
      expect(slist[29], {'1': 'First', '2': 'Second', '3': 'Third'});
    });
  });
  group('Issues', () {
    group('Issue 9', () {
      test('9-1', () {
        print('9-1 - invalid decoding of arrays');
        //        81          # array(1)
        //        A3       # map(3)
        //        01    # unsigned(1)
        //        A1    # map(1)
        //        01 # unsigned(1)
        //        01 # unsigned(1)
        //        03    # unsigned(3)
        //        A1    # map(1)
        //        01 # unsigned(1)
        //        01 # unsigned(1)
        //        0C    # unsigned(12)
        //        A1    # map(1)
        //        01 # unsigned(1)
        //        01 # unsigned(1)

        const hexString = '81a301a1010103a101010ca10101';
        final bytes = hex.decode(hexString);
        final inst = cbor.Cbor();
        inst.decodeFromList(bytes);
        print(inst.decodedPrettyPrint());
        final decoded = inst.getDecodedData();
        expect(decoded[0], [
          {
            1: {1: 1},
            3: {1: 1},
            12: {1: 1}
          }
        ]);
      });
      test('9-2', () {
        print('9-2 - invalid decoding of arrays');
        //        81             # array(1)
        //        A3          # map(3)
        //        01       # unsigned(1)
        //        A1       # map(1)
        //        01    # unsigned(1)
        //        02    # unsigned(2)
        //        03       # unsigned(3)
        //        A1       # map(1)
        //        01    # unsigned(1)
        //        81    # array(1)
        //        01 # unsigned(1)
        //        0C       # unsigned(12)
        //        A1       # map(1)
        //        01    # unsigned(1)
        //        02    # unsigned(2)

        const hexString = '81A301A1010203A10181010CA10102';
        final bytes = hex.decode(hexString);
        final inst = cbor.Cbor();
        inst.decodeFromList(bytes);
        print(inst.decodedPrettyPrint());
        final decoded = inst.getDecodedData();
        expect(decoded[0], [
          {
            1: {1: 2},
            3: {
              1: [1]
            },
            12: {1: 2}
          }
        ]);
      });
    });
    group('Issue 10', ()
    {
      test('10-1', () {
        final inst = cbor.Cbor();
        final encoder = inst.encoder;

        encoder.writeArrayImpl([], true, 1);
        // [{1 : 123456789}]
        encoder.writeMapImpl({1:null}, true, 1);
        encoder.writeInt(1);
        encoder.writeTag(2); // BigInt
        encoder.writeInt(BigInt.from(123456789).toInt());
        encoder.writeBreak();
        encoder.writeBreak();

        final buff = inst.output.getData();
        List<int> encodedBytes = buff.buffer.asUint8List();

        inst.decodeFromList(encodedBytes);

        final decodedData = inst.getDecodedData();
        final hexDump = hex.encode(encodedBytes);
        expect(hexDump,'9fbf01f601c21a075bcd15ffff');
        expect(decodedData, [[{1: 123456789}]]);
      });
    });

  });
}
