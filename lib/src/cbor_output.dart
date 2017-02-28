/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// A base class for encoder output.
/// Derived classes must implement these methods as a minimum
/// to provide full CBOR encoding.

abstract class Output {
  /// The encoded output buffer
  typed.Uint8Buffer _buffer;

  /// The paused buffer
  typed.Uint8Buffer _pauseBuffer;

  /// Pause indicator
  bool _paused = false;

  /// Position of the last mark operation
  int _markPos = 0;

  /// Get the current output buffer
  typed.Uint8Buffer getData() {
    return _buffer;
  }

  /// Clear the buffer
  void clear();

  /// Current buffer size
  int size();

  /// Write asingle byte
  void putByte(int value);

  /// Write multiple bytes
  void putBytes(typed.Uint8Buffer data);

  /// Mark the current buffers position. Used for rollback
  /// in conjunction with the resetToMark method. Only one mark
  /// can be in force at a time, they cannot be nested. Marking
  /// only applies to the encoded output buffer.
  void mark();

  /// Resets the buffer back to its last mark position, used to protect
  /// complex encodes(arrays, maps) that may not work.
  void resetToMark();

  /// Pauses encoding, copies the encoded output buffer to the pause buffer,
  /// and clears the output buffer. Further encoding carries on as normal
  /// in the output buffer. Used to encode CBOR items as standalone entities
  /// for later inclusion in the main encoding stream, e.g map values. Hs
  /// no effect if already paused.
  void pause();

  /// Restart after pause, copies the pause buffer back into the output buffer,
  /// if append is true the current output buffer contents are appended to the
  /// pause buffer.
  void restart([bool append = false]);
}
