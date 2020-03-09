// Copyright (c) 2017, steve. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cbor/cbor.dart' as cbor;

/// A simple encoding sequence followed by a self decode and a pretty print
/// and JSON output.
int main() {
  // Get our cbor instance, always do this,it correctly
  // initialises the decoder.
  final inst = cbor.Cbor();

  // Get our encoder
  final encoder = inst.encoder;

  // Encode some values
  encoder.writeArray(<int>[1, 2, 3]);
  encoder.writeFloat(67.89);
  encoder.writeInt(10);
  // Note you can encode maps with either string or integer keys,
  // Cbor also decodes maps with these keys, however, Cbor only
  // converts maps with string keys to JSON.
  encoder.writeMap(<int, String>{1: 'one', 2: 'two'});
  encoder.writeString('hello');

  // You can now get the encoded output.
  final buff = inst.output.getData();

  // and do what you want with it
  buff.toString();

  // Or, we can decode ourselves
  inst.decodeFromInput();

  // Then pretty print it
  print(inst.decodedPrettyPrint());

  return 0;
}
