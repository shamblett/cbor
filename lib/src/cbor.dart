/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

// ignore_for_file: unnecessary_getters_setters
// ignore_for_file: avoid_as

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
  Input _input;
  Decoder _decoder;
  Listener _listener;

  /// Input
  Input get input => _input;

  set input(Input val) => _input = val;

  /// Decoder
  Decoder get decoder => _decoder;

  /// Output
  Output get output => _output;

  /// Buffer
  typed.Uint8Buffer get buffer => _buffer;

  /// Listener
  Listener get listener => _listener;

  set listener(Listener value) {
    _listener = value;
  }

  /// Decode from a byte buffer payload
  void decodeFromBuffer(typed.Uint8Buffer buffer) {
    final ListenerStack listener = _listener as ListenerStack;
    listener.stack.clear();
    _output.clear();
    _input = Input(buffer, buffer.length);
    _decoder = Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Decode from a list of integer payload
  void decodeFromList(List<int> ints) {
    final ListenerStack listener = _listener as ListenerStack;
    listener.stack.clear();
    _output.clear();
    final typed.Uint8Buffer buffer = typed.Uint8Buffer();
    buffer.addAll(ints);
    _input = Input(buffer, buffer.length);
    _decoder = Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Decode from the input attribute, i.e decode what we have
  /// just encoded.
  void decodeFromInput() {
    final ListenerStack listener = _listener as ListenerStack;
    listener.stack.clear();
    _input = Input(_output.getData(), _output.size());
    _decoder = Decoder.withListener(_input, _listener);
    _decoder.run();
  }

  /// Get the decoded data as a list
  List<dynamic> getDecodedData() {
    final ListenerStack listener = _listener as ListenerStack;
    return listener.stack.walk();
  }

  /// Get the decoded hints
  List<dataHints> getDecodedHints() {
    final ListenerStack listener = _listener as ListenerStack;
    return listener.stack.hints();
  }

  /// Pretty print the decoded data
  // ignore: avoid_positional_boolean_parameters
  String decodedPrettyPrint([bool withHints = false]) {
    String ret = '';
    final List<dynamic> values = getDecodedData();
    List<dataHints> hints;
    if (withHints) {
      hints = getDecodedHints();
    }
    final int length = values.length;
    for (int i = 0; i < length; i++) {
      // ignore: use_string_buffers
      ret += 'Entry $i   : Value is => ${values[i].toString()}\n';
      if (withHints) {
        ret += '          : Hint is => ${hints[i].toString()}\n';
      }
    }
    return ret;
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
