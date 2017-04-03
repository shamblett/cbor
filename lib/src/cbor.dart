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
    _output = new OutputStandard();
    _encoder = new Encoder(output);
    _listener = new ListenerStack();
  }

  /// Decoder
  typed.Uint8Buffer _buffer;
  Input _input;
  Decoder _decoder;
  Listener _listener;

  Input get input => _input;

  set input(Input val) => _input = val;

  Decoder get decoder => _decoder;

  Output get output => _output;

  typed.Uint8Buffer get buffer => _buffer;

  Listener get listener => _listener;

  set listener(Listener value) {
    _listener = value;
  }

  /// Decode from a byte buffer payload
  void decodeFromBuffer(typed.Uint8Buffer buffer) {
    _listener.stack.clear();
    _input = new Input(buffer, buffer.length);
    _decoder = new Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Decode from a list of integer payload
  void decodeFromList(List<int> ints) {
    _listener.stack.clear();
    final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
    buffer.addAll(ints);
    _input = new Input(buffer, buffer.length);
    _decoder = new Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Decode from the input attribute.
  void decodeFromInput() {
    _listener.stack.clear();
    _decoder = new Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Get the decoded data as a list
  List<dynamic> getDecodedData() {
    return _listener.stack.walk();
  }

  /// Get the decoded hints
  List<dataHints> getDecodedHints() {
    return listener.stack.hints();
  }

  /// Pretty print the decoded data
  String decodedPrettyPrint([bool withHints = false]) {}

  /// To JSON
  String decodedToJSON() {}

  /// Encoder
  Output _output;
  Encoder _encoder;

  Output get rawOutput => _output;

  Encoder get encoder => _encoder;

  /// Clear the encoded output
  void clearEncoded() {
    _output.clear();
  }
}
