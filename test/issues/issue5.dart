/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */
import 'dart:math';
import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  test('Two 64', () {
    print('Two pow 64 is ${two64}');
   // expect(normalList is List, isTrue);
  });
  test('Two 32', () {
    print('Two pow 32 is $two32');
    expect(two32, 4294967296);
  });
}
