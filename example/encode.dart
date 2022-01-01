/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

/// A simple encoding sequence followed by a self decode and a pretty print.
int main() {
  final value = CborValue([
    [1, 2, 3], // Writes an array
    CborBytes([0x00]), // Writes a byte string
    67.89,
    10,
    // You can encode maps with any value encodable as CBOR as key.
    {
      1: 'one',
      2: 'two',
    },
    'hello',

    // Indefinite length string
    CborEncodeIndefiniteLengthString([
      'hello',
      ' ',
      'world',
    ]),
  ]);

  final bytes = cbor.encode(value);

  final _ = cbor.decode(bytes);

  // Pretty print
  print(cborPrettyPrint(bytes));

  // Print json
  print(const CborJsonEncoder().convert(value));

  return 0;
}
