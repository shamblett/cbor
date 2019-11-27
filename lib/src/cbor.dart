/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The CBOR package main API.
class Cbor {
  /// Construction
  Cbor() {
    init();
    _output = OutputStandard();
    _encoder = Encoder(output);
    _listener = ListenerStack();
  }

  /// Decoder
  typed.Uint8Buffer _buffer;

  /// The input
  Input input;

  Decoder _decoder;

  Listener _listener;

  /// The decoder
  Decoder get decoder => _decoder;

  /// The output
  Output get output => _output;

  /// The buffer
  typed.Uint8Buffer get buffer => _buffer;

  /// Decode from a byte buffer payload
  void decodeFromBuffer(typed.Uint8Buffer buffer) {
    final ListenerStack listener = _listener;
    listener.stack.clear();
    _output.clear();
    input = Input(buffer);
    _decoder = Decoder.withListener(input, _listener);
    _decoder.run();
  }

  /// Decode from a list of integer payload
  void decodeFromList(List<int> ints) {
    final ListenerStack listener = _listener;
    listener.stack.clear();
    _output.clear();
    final typed.Uint8Buffer buffer = typed.Uint8Buffer();
    buffer.addAll(ints);
    input = Input(buffer);
    _decoder = Decoder.withListener(input, _listener);
    _decoder.run();
  }

  /// Decode from the input attribute, i.e decode what we have
  /// just encoded.
  void decodeFromInput() {
    final ListenerStack listener = _listener;
    listener.stack.clear();
    input = Input(_output.getData());
    _decoder = Decoder.withListener(input, _listener);
    _decoder.run();
  }

  /// Get the decoded data as a list
  List<dynamic> getDecodedData() {
    final ListenerStack listener = _listener;
    return listener.stack.walk();
  }

  /// Get the decoded hints
  List<dataHints> getDecodedHints() {
    final ListenerStack listener = _listener;
    return listener.stack.hints();
  }

  /// Pretty print the decoded data
  // ignore: avoid_positional_boolean_parameters
  String decodedPrettyPrint([bool withHints = false]) {
    final StringBuffer ret = StringBuffer();
    final List<dynamic> values = getDecodedData();
    List<dataHints> hints;
    if (withHints) {
      hints = getDecodedHints();
    }
    final int length = values.length;
    for (int i = 0; i < length; i++) {
      ret.write('Entry $i   : Value is => ${values[i].toString()}\n');
      if (withHints) {
        ret.write('          : Hint is => ${hints[i].toString()}\n');
      }
    }
    return ret.toString();
  }

  /// To JSON, only supports strings as map keys.
  /// Returns null if the conversion fails.
  String decodedToJSON() {
    String ret;
    try {
      ret = convertor.json.encode(getDecodedData());
    } on Exception {
      return null;
    }
    // Remove the [] from the JSON string
    return ret.substring(1, ret.length - 1);
  }

  /// Encoder
  Output _output;
  Encoder _encoder;

  /// Raw output
  Output get rawOutput => _output;

  /// Encoder
  Encoder get encoder => _encoder;

  /// Clear the encoded output
  void clearEncoded() {
    _output.clear();
  }
}
