/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The standard output class.

class OutputStandard extends Output {
  OutputStandard() {
    this._buffer = new typed.Uint8Buffer();
  }

  /// Overridden methods
  void clear() {
    _buffer.clear();
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

  void pause() {

  }

  void restart([bool append = false]) {

  }

  /// Additional methods

  List<int> getDataAsList() {
    return _buffer.toList();
  }


}
