/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
  group('Original C++ tests', () {
    test('Encode/Decode confidence -> ', () {
      // Encoding
      final cbor.OutputDynamic output = new cbor.OutputDynamic();
      final cbor.Encoder encoder = new cbor.Encoder(output);
      encoder.writeArray([9]);
      encoder.writeInt(123);
      encoder.writeInt(-457);
      encoder.writeString("barrr");
      encoder.writeInt(321);
      encoder.writeInt(322);
      encoder.writeString("foo");
      encoder.writeBool(true);
      encoder.writeBool(false);
      encoder.writeNull();
      encoder.writeUndefined();

      // Decoding
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.ListenerDebug listener = new cbor.ListenerDebug();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
    });
  });
}
