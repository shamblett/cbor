/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

enum DecoderState {
  STATE_TYPE,
  STATE_PINT,
  STATE_NINT,
  STATE_BYTES_SIZE,
  STATE_BYTES_DATA,
  STATE_STRING_SIZE,
  STATE_STRING_DATA,
  STATE_ARRAY,
  STATE_MAP,
  STATE_TAG,
  STATE_SPECIAL,
  STATE_ERROR
}

class Decoder {
  Listener _listener;
  Input _input;
  DecoderState _state;
  int _currentLength;

  Decoder(Input input) {}

  Decoder.withListener(Input input, Listener listener) {}

  void run() {}

  void setListener(Listener listenerInstance) {}
}
