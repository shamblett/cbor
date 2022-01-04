/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

/// An exception raised when decoding.
class CborMalformedException extends FormatException {
  const CborMalformedException(String message, [int? offset])
      : super(message, offset);

  @override
  String toString() {
    var string = 'Malformed CBOR';
    if (offset != null) {
      string += ' at $offset';
    }
    string += ': $message';

    return string;
  }
}

/// Raised when object could not be codified due to cyclic references.
class CborCyclicError extends Error {
  CborCyclicError(this.cause);

  final Object cause;

  @override
  String toString() {
    return 'Cbor cyclic error';
  }
}
