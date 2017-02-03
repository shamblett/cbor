// Copyright (c) 2016, steve. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
  group('Original tests', () {
    test('Encode/Decode', () {
      cbor.OutputDynamic output = new cbor.OutputDynamic();
      cbor.Encoder encoder = new cbor.Encoder(output);
      encoder.writeArray(9);
      {
        encoder.writeInt(123);
        encoder.writeString("bar");
        encoder.writeInt(321);
        encoder.writeInt(321);
        encoder.writeString("foo");
        encoder.writeBool(true);
        encoder.writeBool(false);
        encoder.writeNull();
        encoder.writeUndefined();
      }

      // decoding
      cbor.Input input = new cbor.Input(output.getData(), output.size());
      cbor.ListenerDebug listener = new cbor.ListenerDebug();
      cbor.Decoder decoder = new cbor.Decoder.withListener(input, listener);
      decoder.run();
    });
  });
}
