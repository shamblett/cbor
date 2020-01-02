// Copyright (c) 2017, steve. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cbor/cbor.dart' as cbor;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

/// A more complex encoding sequence followed by a self decode and a JSON
/// output.
int main() {
  // Get our cbor instance, always do this,it correctly
  // initialises the decoder.
  final cbor.Cbor inst = cbor.Cbor();

  // Get our encoder
  final cbor.Encoder encoder = inst.encoder;

  // Encode some values
  encoder.writeArray(<int>[1, 2, 3]);
  encoder.writeFloat(67.89);
  encoder.writeInt(10);
  // Note you can encode maps with either string or integer keys,
  // Cbor also decodes maps with these keys, however, Cbor only
  // converts maps with string keys to JSON.
  encoder.writeMap(<String, String>{'1': 'one', '2': 'two'});
  encoder.writeString('hello');
  // Ok, lets get a bit complex, pause the encoder, encode
  // a Cbor sequence and restart the encoder. See RFC 7049
  // for details of what we are doing here, most users will not
  // need to do stuff like this.

  // Pause encoding, and start a encoding stream, there
  // can be only one pause at any one time. We are encoding
  // an indefinite array sequence here. You can do this by encoding
  // an array as indefinite also.
  inst.output.pause();
  encoder.writeArray(<int>[2, 3], true);
  // You MUST end indefinite sequences with a break, only you know
  // when your sequence ends, not the encoder.
  encoder.writeBreak();

  // Ok, restart encoding and append our partial encoding stream.
  inst.output.restart(true);

  // Bit more, this is a tag encode
  encoder.writeDateTime('01:01:01 16-02-2017');

  // Another(simpler) way to do the above array encode.
  // There are some sequences you will have to pause and restart
  // to encode correctly, this however is advanced stuff.
  encoder.writeArray(<int>[5, 6, 7], true);
  encoder.writeBreak();

  // Indefinites can be nested, the indfinite string below will
  // now appear as an array member.
  encoder.writeArray(<int>[8, 9, 10], true);

  // Indefinite string, treated as a chunk, refer to RFC 7049
  encoder.writeString('Strea', true);
  // This is now encoded as a string chunk and appended to the
  // string above to give 'Streaming' in the output.
  encoder.writeString('ming');

  // Write breaks for BOTH the opened indefinite items above.
  encoder.writeBreak();
  encoder.writeBreak();

  // Decode ourselves and pretty print it, this time with data hints
  inst.decodeFromInput();
  print(inst.decodedPrettyPrint(true));

  // Finally to JSON
  print(inst.decodedToJSON());

  // JSON output is :-
  // [1,2,3],67.89,10,{'1':'one','2':'two'},'hello',[2,3],
  // '01:01:01 16-02-2017',[5,6,7],[8,9,10,'Streaming']
  return 0;
}
