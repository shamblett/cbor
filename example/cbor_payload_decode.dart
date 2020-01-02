// Copyright (c) 2017, steve. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart';

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

/// A payload based decode.
int main() {
  // Get our cbor instance, always do this,it correctly
  // initialises the decoder.
  final cbor.Cbor inst = cbor.Cbor();

  // Assume we have received a CBOR encoded byte buffer from the network.
  // The byte sequence below gives :-
  // {"a": "A", "b": "B", "c": "C", "d": "D", "e": "E"}
  final List<int> payload = <int>[
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
  ];

  final Uint8Buffer payloadBuffer = Uint8Buffer();
  payloadBuffer.addAll(payload);

  // Decode from the buffer, you can also decode from the
  // int list if you prefer.
  inst.decodeFromBuffer(payloadBuffer);

  // Pretty print, note you must decode first before using
  // prettyprint or JSON, these are only transformers.
  print(inst.decodedPrettyPrint());

  // JSON, maps can only have string keys to decode to JSON
  print(inst.decodedToJSON());

  return 0;
}
