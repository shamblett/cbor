/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */
import 'dart:convert';

import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
    test('1', () {
      var cleanedToken = 'p0F2AkF0Gl2AX-JDdHRsCkNyZXOkRGNoYW6gQ2dycKBDdXNyoWl1LTMzNTIwNTUPQ3NwY6Fpcy0xNzA3OTgzGB9DcGF0pERjaGFuoENncnCgQ3VzcqBDc3BjoERtZXRhoENzaWdYINqGs2EyEMHPZrp6znVqTBzXNBAD_31hUH3JuUSWE2A6';
      var payload = base64Decode(cleanedToken);
      print(payload);
      final inst = cbor.Cbor();
      inst.decodeFromList(payload);
      var decoded = inst.getDecodedData();
      print(decoded);
      // 161, 105, 117, 45, 51, 51, 53, 50, 48, 53, 53, 15
    });
    test('2', () {
      final inst = cbor.Cbor();
      inst.encoder.writeMap({
        "chan":{},
        "grp":{},
        "usr":{"myuser1":19},
        "spc":{"myspace1":11}
      });
     inst.decodeFromInput();
     var decoded = inst.getDecodedData();
     print(decoded);
     expect(decoded,[{"chan": {}, "grp": {}, "usr": {"myuser1": 19}, "spc": {"myspace1": 11}}]);
    });
}
