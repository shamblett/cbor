/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The CBOR package main API.
class Cbor {

  /// Decoder
  typed.Uint8Buffer _buffer;
  Input _input;
  Decoder _decoder;
  Listener _listener;

  Input get input => _input;

  Decoder get decoder => _decoder;

  Output get output => _output;

  typed.Uint8Buffer get buffer => _buffer;

  Listener get listener => _listener;

  set listener(Listener value) {
    _listener = value;
  }

  /// Decode from a byte buffer payload
  void decodeFromBuffer(typed.Uint8Buffer buffer) {

  }

  /// Decode from a list of integer payload
  void decodeFromList(List<int> ints) {

  }

  /// Get the decoded data as a list
  List<dynamic> getDecodedData() {

  }

  /// Get the decoded hints
  List<dataHints> getDecodedHints() {

  }

  /// Pretty print the decoded data
  String decodedPrettyPrint() {

  }

  /// To JSON
  String decodedToJSON() {

  }

  /// Encoder
  Output _output;
  Encoder _encoder;

  Output get output => _output;

  Encoder get encoder => _encoder;

}
