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
    _buffer = typed.Uint8Buffer();
    _pauseBuffer = typed.Uint8Buffer();
  }

  @override
  void clear() {
    _buffer.clear();
  }

  @override
  int size() => _buffer.length;

  @override
  void putByte(int value) {
    _buffer.add(value);
  }

  @override
  void putBytes(typed.Uint8Buffer data) {
    _buffer.addAll(data);
  }

  @override
  void mark() {
    _markPos = _buffer.length;
  }

  @override
  void resetToMark() {
    if (_buffer.length > _markPos) {
      _buffer.removeRange(_markPos, _buffer.length);
    }
  }

  @override
  void pause() {
    if (!_paused) {
      _pauseBuffer.clear();
      _pauseBuffer.addAll(_buffer);
      _buffer.clear();
      _paused = true;
    }
  }

  @override
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

  List<int> getDataAsList() => _buffer.toList();
}
