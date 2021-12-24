/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

/// A stream based decode.
Future<int> main() async {
  // Assume we have received a CBOR encoded byte buffer from the network.
  // The byte sequence below gives :-
  // {'a': 'A', 'b': 'B', 'c': 'C', 'd': 'D', 'e': 'E'}
  final payload = Stream.fromIterable([
    0xa5,
    0x61,
    0x61,
    0x61,
    0x41,
    0x61,
    0x62,
    0x61,
    0x42,
    0x61,
    0x63,
    0x61,
    0x43,
    0x61,
    0x64,
    0x61,
    0x44,
    0x61,
    0x65,
    0x61,
    0x45
  ].map((x) => [x]));

  // Decode using stream transforming
  // We use single because this is a single item
  final decoded = await payload.transform(cbor.decoder).single;

  // Print preview of decoded item
  // Should print {a: A, b: B, c: C, d: D, e: E}
  print(decoded);

  return 0;
}
