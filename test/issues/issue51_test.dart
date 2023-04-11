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
      'lists do not change definite/indefinite type when parsing and re-encoding',
      () {
    final codec = CborCodec().fuse(HEX);
    final expected =
        "84a6008482582069f647781a51876c03bce5915cafc494f45456dec10d2cf7d6a730dcd338ce7101825820b187362541bcede39962010795394b2d6a86b943b2bd8db3ed64044e199b316701825820b187362541bcede39962010795394b2d6a86b943b2bd8db3ed64044e199b316702825820fd67551fa18fc075a8687cb2621378ccbdf55d66b10c492753d38e29e491673903018383583911a65ca58a4e9c755fa830173d2a5caed458ac0c73f97db7faae2e7e3b52563c5410bff6a0d43ccebb7c37e1f69f5eb260552521adff33b9c21a0cef1a665820a73e566454372ae65eb101d0f14a6e507fdb9593160269b476f595f7658dc34982583901ed49d9adbd06592290b9a16032375d6b79d4df760cad0d9bca9555fc4199f66b16ce9eb5849ed96473face025b2e9bcbdf1e352ad43629811abff58df482583901ed49d9adbd06592290b9a16032375d6b79d4df760cad0d9bca9555fc4199f66b16ce9eb5849ed96473face025b2e9bcbdf1e352ad4362981821a003630d0ad581c0e14267a8020229adc0184dd25fa3174c3f7d6caadcb4425c70e7c04a14a756e736967303131313801581c160a880d9fc45380737cb7e57ff859763230aab28b3ef6a84007bfcca1444d4952411864581c16fdd33c86af604e837ae57d79d5f0f1156406086db5f16afb3fcf51a14544474f4c441a05f5e100581c1f362a4df39f451401e44fee30f27eb39712d66aae375f539be94ed6a14c546865496c6961643238303401581c29d222ce763455e3d7a09a665ce554f00ac89d2e99a1a83d267170c6a1434d494e1a00701aae581c2eeb39204c3d104b40ec56bfd612bb1067fdea45de15f3a8aad9db71a14d4d616769634b6f6e673235303201581c682fe60c9918842b3323c43b5144bc3d52a23bd2fb81345560d73f63a1444e45574d1a004c4b40581ca0028f350aaabe0545fdcb56b039bfb08e4bb4d8c4d7c3c7d481c235a145484f534b591a000f4240581caf2e27f580f7f08e93190a81f72462f153026d06450924726645891ba144445249501a7de7b663581cb6a7467ea1deb012808ef4e87b5ff371e85f7142d7b356a40d9b42a0a1581e436f726e75636f70696173205b76696120436861696e506f72742e696f5d1a004c4b40581cc68307e7ca850513507f1498862a57c7f4fae7ba8e84b8bc074093a9a14444494253191388581cdfc825363afcdff0f5ec3171f0a29b1d345d271714aa9b2a552b6bbfa148416e74546f6b656e1832581ce4214b7cce62ac6fbba385d164df48e157eae5863521b4b67ca71d86a158206aa2153e1ae896a95539c9d62f76cedcdabdcdf144e564b8955f609d660cf6a21a0211e121021a000355c5031a0557e4ee075820b64602eebf602e8bbce198e2a1d6bbb2a109ae87fa5316135d217110d6d946490b58205109fa2ce7968f8cc211dba68e338a4b620db1a35108aad7ff6b953ad86890dba1049fd8799fd8799fd8799f581ced49d9adbd06592290b9a16032375d6b79d4df760cad0d9bca9555fcffd8799fd8799fd8799f581c4199f66b16ce9eb5849ed96473face025b2e9bcbdf1e352ad4362981ffffffffd8799fd8799f581ced49d9adbd06592290b9a16032375d6b79d4df760cad0d9bca9555fcffd8799fd8799fd8799f581c4199f66b16ce9eb5849ed96473face025b2e9bcbdf1e352ad4362981ffffffffd87a80d8799fd8799f581c29d222ce763455e3d7a09a665ce554f00ac89d2e99a1a83d267170c6434d494eff1a84369796ff1a001e76a61a001e8480fffff5a11902a2a1636d736781781c4d696e737761703a205377617020457861637420496e204f72646572";
    final cbor = codec.decode(expected);
    final actual = codec.encode(cbor);

    expect(actual, expected);
  });

  test(
      'indefinite length maps do not change definite/indefinite type when parsing and re-encoding',
      () {
    // This is an indefinite length map
    final expected = [
      0xbf,
      0x63,
      0x64,
      0x75,
      0x6e,
      0xf5,
      0x63,
      0x41,
      0x6d,
      0x74,
      0x21,
      0xff
    ];
    final cbor = cborDecode(expected);
    final actual = cborEncode(cbor);

    expect(actual, expected);
  });

  test(
      'definite length maps do not change definite/indefinite type when parsing and re-encoding',
      () {
    // This is an definite length map
    final expected = [
      0xa2,
      0x63,
      0x64,
      0x75,
      0x6e,
      0xf5,
      0x63,
      0x41,
      0x6d,
      0x74,
      0x21
    ];
    final cbor = cborDecode(expected);
    final actual = cborEncode(cbor);

    expect(actual, expected);
  });

  test(
      'definite length byte arrays do not change definite/indefinite type when parsing and re-encoding',
      () {
    // This is an indefinite length byte array
    final expected = [0x5f, 0x42, 0x01, 0x02, 0x43, 0x03, 0x04, 0x05, 0xff];
    final cbor = cborDecode(expected);
    final actual = cborEncode(cbor);

    expect(actual, expected);
  });
  test(
      'indefinite length byte arrays do not change definite/indefinite type when parsing and re-encoding',
      () {
    // This is an definite length byte array
    final expected = [0x45, 0x01, 0x02, 0x03, 0x04, 0x05];
    final cbor = cborDecode(expected);
    final actual = cborEncode(cbor);

    expect(actual, expected);
  });
}
