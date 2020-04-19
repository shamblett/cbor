/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 19/04/2020
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart' as cbor;

/// An example of using the List Builder class.
/// List builder is used to build lists with complex entries such as tag values, indefinite sequences
/// and the output of other list or map builders.
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

  // Get our list builder
  final listBuilder = cbor.ListBuilder.builder();

  // Add some tag types to the list
  listBuilder.writeURI('a/ur1');
  listBuilder.writeEpoch(1234567899);
  listBuilder.writeDateTime('19/04/2020');

  // Get our built list output and add it to the encoding stream.
  // Use the addBuilderOutput method to add built output to the encoder.
  // You can use the addBuilderOutput method on the list builder to add
  // the output of other list or map builders to its encoding stream.
  final listBuilderOutput = listBuilder.getData();
  encoder.addBuilderOutput(listBuilderOutput);

  // Add another value
  encoder.writeRegEx('^[12]g');

  // Decode ourselves and pretty print it.
  inst.decodeFromInput();
  print(inst.decodedPrettyPrint(false));

  // Finally to JSON
  print(inst.decodedToJSON());

  // JSON output is :-
  // [1,2,3],67.89,10,["a/ur1",1234567899,"19/04/2020"],"^[12]g"
  return 0;
}
