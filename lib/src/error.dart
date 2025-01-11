/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

/// An exception raised when decoding.
class CborMalformedException extends FormatException {
  const CborMalformedException(super.message, [int? super.offset]);

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
