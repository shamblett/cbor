// Copyright (c) 2017, steve. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart';

/// A more complex encoding sequence followed by a self decode and a JSON
/// output.
int main() {
  // Get our cbor instance, always do this,it correctly
  // initialises the decoder.
  final cbor.Cbor inst = new cbor.Cbor();

  // Get our encoder
  final cbor.Encoder encoder = inst.encoder;

  // Encode some values
  encoder.writeArray([1, 2, 3]);
  encoder.writeFloat(67.89);
  encoder.writeInt(10);
  // Note you can encode maps with either string or integer keys,
  // Cbor also decodes maps with these keys, however, Cbor only
  // converts maps with string keys to JSON.
  encoder.writeMap({"1": "one", "2": "two"});
  encoder.writeString("hello");
  // Ok, lets get a bit complex, pause the encoder, encode
  // a Cbor sequence and restart the encoder. See RFC 7049
  // for details of what we are doing here, most users will not
  // need to do stuff like this.

  // Pause encoding, and start a new encoding stream, there
  // can be only one pause at any one time. We are encoding
  // an indefinite array sequence here. You can do this by encoding
  // an array as indefinite also.
  inst.output.pause();
  encoder.writeArray([2, 3], true);
  encoder.writeBreak();

  // Ok, restart encoding and append our partial encoding stream.
  inst.output.restart(true);

  // Bit more, this is a tag encode
  encoder.writeDateTime("01:01:01 16-02-2017");

  // Another(simpler) way to do the above array encode.
  // There are some sequences you will have to pause and restart
  // to encode correctly, this however is advanced stuff.
  encoder.writeArray([5, 6, 7], true);
  encoder.writeBreak();

  // Decode ourselves and pretty print it, this time with data hints
  inst.decodeFromInput();
  print(inst.decodedPrettyPrint(true));

  // Finally to JSON
  print(inst.decodedToJSON());

  return 0;
}
