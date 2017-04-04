/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/03/2017
 * Copyright :  S.Hamblett
 */
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'package:typed_data/typed_data.dart' as typed;
import 'dart:io';

void main() {
  // Common
  final cbor.Cbor inst = new cbor.Cbor();
  final List<int> data = [
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
  ];

  group("Decoder", () {
    test('From buffer -> ', () {
      final typed.Uint8Buffer buff = new typed.Uint8Buffer();
      buff.addAll(data);
      inst.decodeFromBuffer(buff);
      final List<dynamic> decode = inst.getDecodedData();
      expect(decode[0], {
        "p16": 16,
        "uni": "\u901A\u8A0A\u9023\u63A5\u57E0 (COM1)",
        "n1": -1,
        "ascii": "hello",
        "nil": null,
        "empty_arr": [],
        "p65535": 65535,
        "bin": [0x31, 0x32, 0x55],
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
    });

    test('From list -> ', () {
      inst.decodeFromList(data);
      final List<dynamic> decode = inst.getDecodedData();
      expect(decode[0], {
        "p16": 16,
        "uni": "\u901A\u8A0A\u9023\u63A5\u57E0 (COM1)",
        "n1": -1,
        "ascii": "hello",
        "nil": null,
        "empty_arr": [],
        "p65535": 65535,
        "bin": [0x31, 0x32, 0x55],
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
      print("Pretty Print");
      print(inst.decodedPrettyPrint());
      print("JSON");
      final String jsonString = inst.decodedToJSON();
      print(jsonString);
      expect(jsonString,
          '[{"p16":16,"uni":"通訊連接埠 (COM1)","n1":-1,"ascii":"hello","nil":null,"empty_arr":[],"p65535":65535,"bin":[49,50,85],"n2G":-2147483648,"p1":1,"n65535":-65535,"n16":-16,"zero":0,"arr":[1,2,3],"obj":{"foo":"bar"},"bfalse":false,"p255":255,"p2G":2147483648,"n255":-255,"btrue":true}]');
    });

    test('Hints -> ', () {
      // Encoding
      inst.encoder.writeDateTime("2013-03-21T20:04:00Z");
      inst.encoder.writeEpoch(1234567);
      final typed.Uint8Buffer data = new typed.Uint8Buffer();
      data.addAll([01, 02, 03, 89]);
      inst.encoder.writeBytes(data);
      data[3] = 90;
      inst.encoder.writeBase64(data);
      data[3] = 91;
      inst.encoder.writeCborDi(data);
      data[3] = 92;
      inst.encoder.writeBase64URL(data);
      data[3] = 93;
      inst.encoder.writeBase16(data);
      inst.encoder.writeURI("example.com");

      // Decoding
      final cbor.Input dataIn =
      new cbor.Input(inst.rawOutput.getData(), inst.rawOutput.size());
      inst.input = dataIn;
      inst.decodeFromInput();
      final List<cbor.dataHints> hints = inst.getDecodedHints();
      expect(hints[0], cbor.dataHints.dateTimeString);
      expect(hints[1], cbor.dataHints.dateTimeEpoch);
      expect(hints[2], cbor.dataHints.none);
      expect(hints[3], cbor.dataHints.base64);
      expect(hints[4], cbor.dataHints.encodedCBOR);
      expect(hints[5], cbor.dataHints.base64Url);
      expect(hints[6], cbor.dataHints.base16);
      expect(hints[7], cbor.dataHints.uri);
      print("Pretty Print");
      print(inst.decodedPrettyPrint(true));
      print("JSON");
      final String jsonString = inst.decodedToJSON();
      print(jsonString);
      expect(jsonString,
          '["2013-03-21T20:04:00Z",1234567,[1,2,3,89],[1,2,3,90],[1,2,3,91],[1,2,3,92],[1,2,3,93],"example.com"]');
    });
  });
}
