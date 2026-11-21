/*
 * Package : Cbor
 * Author : bardrop
 * Date   : 21/11/2026
 * Copyright :  bardrop
 */
import 'package:cbor/cbor.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  group('Tags on integers are kept when decoded', () {
    for (final hex in [
      'd904d201', // small unsigned
      'd904d238c2', // small negative
      'd904d21bffffffffffffffff', // 64-bit unsigned
      'd904d23bffffffffffffffff', // 64-bit negative
      'd904d2d9162e1903e8', // two tags
    ]) {
      test(hex, () {
        final decoded = cbor.decode(HEX.decode(hex));
        expect(decoded, isA<CborInt>());
        expect(decoded.tags, isNotEmpty);
        expect(HEX.encode(cbor.encode(decoded)), hex);
      });
    }
  });
}
