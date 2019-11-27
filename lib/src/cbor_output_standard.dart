/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// The standard output class.
class OutputStandard extends Output {
  /// Construction
  @override
  OutputStandard() {
    this._buffer = new typed.Uint8Buffer();
    this._pauseBuffer = new typed.Uint8Buffer();
  }

  @override
  void clear() {
    _buffer.clear();
  }

  @override
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
    if (!_paused) {
      _pauseBuffer.clear();
      _pauseBuffer.addAll(_buffer);
      _buffer.clear();
      _paused = true;
    }
  }

  void restart([bool append = false]) {
    if (_paused) {
      if (append) {
        _pauseBuffer.addAll(_buffer);
      }
      _buffer.clear();
      _buffer.addAll(_pauseBuffer);
      _paused = false;
    }
  }

  /// Additional methods.

  List<int> getDataAsList() {
    return _buffer.toList();
  }
}
