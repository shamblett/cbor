/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */
import 'package:convert/convert.dart';
import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  test('63254', () {
    final decoded = cbor.decode([25, 247, 22]);

    expect(decoded, CborSmallInt(63254));
  });
}
