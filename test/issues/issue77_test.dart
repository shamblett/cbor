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
  test(
    'CBOR List missing tags when decoded',
    () {
      const original = "82d8405820e8824c7a0c4e4d7d58009ba1675a72656f4899278906d9523cf0408f1a98f7fb00";

      print(cborDecode(HEX.decode(original)));
      print(cborPrettyPrint(HEX.decode(original)));
    },
  );
}
