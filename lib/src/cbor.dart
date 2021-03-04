/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The CBOR package main API.
class Cbor {
  // Decoder
  late Input input;
  late Decoder decoder;

  // Encoder
  final Output output = OutputStandard();
  late final Encoder encoder;

  final Listener listener = ListenerStack();
  final _decodeStack = DecodeStack();
  late final typed.Uint8Buffer buffer;

  // Raw output
  Output get rawOutput => output;

  /// Construction
  Cbor() {
    init();

    encoder = Encoder(output);
  }

  /// Decode from a byte buffer payload
  void decodeFromBuffer(typed.Uint8Buffer buffer) {
    output.clear();
    input = Input(buffer);
    listener.itemStack.clear();
    decoder = Decoder.withListener(input, listener);
    decoder.run();
  }

  /// Decode from a list of integer payload
  void decodeFromList(List<int> ints) {
    output.clear();
    final buffer = typed.Uint8Buffer();
    buffer.addAll(ints);
    input = Input(buffer);
    listener.itemStack.clear();
    decoder = Decoder.withListener(input, listener);
    decoder.run();
  }

  /// Decode from the input attribute, i.e decode what we have
  /// just encoded.
  void decodeFromInput() {
    input = Input(output.getData());
    listener.itemStack.clear();
    decoder = Decoder.withListener(input, listener);
    decoder.run();
  }

  /// Get the decoded data as a list.
  List<dynamic>? getDecodedData() {
    _decodeStack.build(listener.itemStack);
    return _decodeStack.walk();
  }

  /// Clear the decode stack
  void clearDecodeStack() => _decodeStack.clear();

  /// Get the decoded hints. Note you must call [getDecodedData()] before
  /// getting the hints.
  List<dataHints> getDecodedHints() {
    return _decodeStack.hints.toList;
  }

  /// Pretty print the decoded data
  String? decodedPrettyPrint([bool withHints = false]) {
    var ret = '';
    final values = getDecodedData();
    if (values == null) {
      return null;
    }

    late List<dataHints> hints;
    if (withHints) {
      hints = getDecodedHints();
    }
    final length = values.length;
    for (var i = 0; i < length; i++) {
      ret += 'Entry $i   : Value is => ${values[i].toString()}\n';
      if (withHints) {
        ret += '          : Hint is => ${hints[i].toString()}\n';
      }
    }
    return ret;
  }

  /// To JSON, only supports strings as map keys.
  /// Returns null if the conversion fails.
  String? decodedToJSON() {
    String ret;
    try {
      ret = convertor.json.encode(getDecodedData());
    } on Exception {
      return null;
    }
    // Remove the [] from the JSON string
    return ret.substring(1, ret.length - 1);
  }

  /// Clear the encoded output
  void clearEncodedOutput() {
    output.clear();
  }
}
