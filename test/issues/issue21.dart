/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:test/test.dart';

void main() {
  test('List Types', () {
    final normalList = <int>[];
    print("Normal list runtime type is ${normalList.runtimeType}");
    expect(normalList is List, isTrue);
  });
  test('MapTypes', () {
    final normalMap = <String, int>{};
    print("Normal map runtime type is ${normalMap.runtimeType}");
    expect(normalMap is Map, isTrue);
  });
}
