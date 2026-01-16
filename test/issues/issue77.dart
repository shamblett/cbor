/*
 * Package : Cbor
 * Author : A. Dochioiu <alex@vespr.xyz>
 * Date   : 11/04/2023
 * Copyright :  A.Dochioiu
 */
import 'package:cbor/cbor.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  test('CBOR List missing tags when decoded', () {
    const original =
        "81D8405820E8824C7A0C4E4D7D58009BA1675A72656F4899278906D9523CF0408F1A98F7FB";
    const originalList = '[$original]';
    final result = cborDecode(HEX.decode(original));
    expect(result.toJson().toString() == originalList, isFalse);
  });
}
