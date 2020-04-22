/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 02/04/2020
 * Copyright :  S.Hamblett
 */
import 'package:convert/convert.dart';
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
  test('9-1', () {
    print('9-1 - invalid decoding of arrays');
    //        81          # array(1)
    //        A3       # map(3)
    //        01    # unsigned(1)
    //        A1    # map(1)
    //        01 # unsigned(1)
    //        01 # unsigned(1)
    //        03    # unsigned(3)
    //        A1    # map(1)
    //        01 # unsigned(1)
    //        01 # unsigned(1)
    //        0C    # unsigned(12)
    //        A1    # map(1)
    //        01 # unsigned(1)
    //        01 # unsigned(1)

    const hexString = '81a301a1010103a101010ca10101';
    final bytes = hex.decode(hexString);
    final inst = cbor.Cbor();
    inst.decodeFromList(bytes);
    print(inst.decodedPrettyPrint());
    final decoded = inst.getDecodedData();
    expect(decoded[0], [
      {
        1: {1: 1},
        3: {1: 1},
        12: {1: 1}
      }
    ]);
  });
  test('9-2', () {
    print('9-2 - invalid decoding of arrays');
    //        81             # array(1)
    //        A3          # map(3)
    //        01       # unsigned(1)
    //        A1       # map(1)
    //        01    # unsigned(1)
    //        02    # unsigned(2)
    //        03       # unsigned(3)
    //        A1       # map(1)
    //        01    # unsigned(1)
    //        81    # array(1)
    //        01 # unsigned(1)
    //        0C       # unsigned(12)
    //        A1       # map(1)
    //        01    # unsigned(1)
    //        02    # unsigned(2)

    const hexString = '81A301A1010203A10181010CA10102';
    final bytes = hex.decode(hexString);
    final inst = cbor.Cbor();
    inst.decodeFromList(bytes);
    print(inst.decodedPrettyPrint());
    final decoded = inst.getDecodedData();
    expect(decoded[0], [
      {
        1: {1: 2},
        3: {
          1: [1]
        },
        12: {1: 2}
      }
    ]);
  });
}
