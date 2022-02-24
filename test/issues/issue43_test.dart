/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  test('SmallInt - 43008', () {
    var a = cbor.encode(const CborSmallInt(43008));
    expect(a, [25, 168, 0]);
    var aa = cbor.decode(a);
    expect(aa is CborSmallInt, true);
    expect((aa as CborSmallInt).toInt(), 43008);
  });
  test('SmallInt - 430080', () {
    var a = cbor.encode(const CborSmallInt(430080));
    expect(a, [26, 0, 6, 144, 0]);
    var aa = cbor.decode(a);
    expect(aa is CborSmallInt, true);
    expect((aa as CborSmallInt).toInt(), 430080);
  });
  test('From issue - 43008', () {
    var a = cbor.encode(const CborSmallInt(43008));
    print(a);
    var aa = cbor.decode(a);
    if (aa is CborSmallInt) {
      print(aa.toInt());
    }
  });
  test('From issue - 430080', () {
    var a = cbor.encode(const CborSmallInt(43008));
    print(a);
    var aa = cbor.decode(a);
    if (aa is CborSmallInt) {
      print(aa.toInt());
    }
  });
  test('From issue - 430080', () {
    var a = cbor.encode(const CborSmallInt(430080));
    print(a);
    var aa = cbor.decode(a);
    if (aa is CborSmallInt) {
      print(aa.toInt());
    }
  });
}
