/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// A dymnamic output class, this allows encoded byte streams to be
/// of any size.

class OutputDynamic extends Output {
  OutputDynamic() {
    this._buffer = new typed.Uint8Buffer();
  }

  void clear() {
    _buffer.clear();
  }

  typed.Uint8Buffer getData() {
    return _buffer;
  }

  List<int> getDataAsList() {
    return _buffer.toList();
  }

  int size() {
    return _buffer.length;
  }

  void putByte(int value) {
    _buffer.add(value);
  }

  void putBytes(typed.Uint8Buffer data) {
    _buffer.addAll(data);
  }

  void mark() {
    _markPos = _buffer.length;
  }

  void resetToMark() {
    if (_buffer.length > _markPos) {
      _buffer.removeRange(_markPos, _buffer.length);
    }
  }
}
