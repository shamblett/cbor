/*
* Package : Cbor
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 02/04/2020
* Copyright :  S.Hamblett
*/
import 'dart:io';

import 'package:cbor/cbor.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Weird JSON conversion',
      () async {
        final currDir = Directory.current.path;
        final f = File('$currDir/test/issue62/raw.txt');
        final decoded = await f.openRead().transform(cbor.decoder).single;
        expect(decoded.toString().isNotEmpty, isTrue);
        print(decoded);
        //final jsonEncoder = CborJsonEncoder();
        //print(jsonEncoder.convert(decoded));
  });
}
