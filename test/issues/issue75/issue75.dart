/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 03/05/2025
 * Copyright :  S.Hamblett
 */

import 'dart:convert';
import 'dart:io';

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  test('Decode time', () {
    final currDir = Directory.current.path;
    final testFile = File('$currDir/test/issues/issue75/long-decode-file.txt');
    final contents = testFile.readAsStringSync();
    final toDecode = base64Decode(contents);
    final start = DateTime.now();
    final decoded = cbor.decode(toDecode);
    final end = DateTime.now();
    final timing = end.difference(start);
    print('Time taken : ${timing.inMilliseconds} ms');
    final jsonEncoder = CborJsonEncoder();
    final json = jsonEncoder.convert(decoded);
    print(json);
  });
}
