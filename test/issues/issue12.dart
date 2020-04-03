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
      // {'v': 2, 't': 1568766012, 'ttl': 1440, 'res': {'chan': {}, 'grp': {}, 'usr': {"user1": 1, "user2": 1}, 'spc': {}}, 'pat': {'chan': {}, 'grp': {}, 'usr': {}, 'spc': {}}, 'meta': {}, 'sig': h'D1D3EFDDA29F2A319C3CD05F187B892DAB4FA147845203866613C6BB49553F6D'}
      var token = 'p0F2AkF0Gl2BeDxDdHRsGQWgQ3Jlc6REY2hhbqBDZ3JwoEN1c3KiZXVzZXIxAWV1c2VyMgFDc3BjoENwYXSkRGNoYW6gQ2dycKBDdXNyoENzcGOgRG1ldGGgQ3NpZ1gg0dPv3aKfKjGcPNBfGHuJLatPoUeEUgOGZhPGu0lVP20=';
      var padding = '';
      if (token.length % 4 == 3) {
        padding = '=';
      } else if (token.length % 4 == 2) {
        padding = '==';
      }
      var cleanedToken = token.replaceAll('_', '/').replaceAll('-', '+') + padding;
      var payload = base64Decode(cleanedToken);
      print(payload);
      final inst = cbor.Cbor();
      inst.decodeFromList(payload);
      var decoded = inst.getDecodedData();
      print(decoded);
      print(inst.decodedToJSON());
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
