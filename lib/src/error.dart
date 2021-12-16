/// An exception raised when decoding.
class CborDecodeException implements Exception {
  const CborDecodeException(this.message, [this.offset]);

  final String message;
  final int? offset;

  @override
  String toString() {
    var string = 'CborDecodeException';
    if (offset != null) {
      string += ' at $offset';
    }
    string += ': $message';

    return string;
  }
}

/// An exception raised by a [FormatException] when decoding.
class CborFormatException extends CborDecodeException {
  CborFormatException(this.formatException, [int? offset])
      : super('\n$formatException', offset);

  final FormatException formatException;
}

/// An error raised when encoding.
abstract class CborEncodeError extends Error {}

/// Raised when object could not be codified due to cyclic references.
class CborCyclicError extends CborEncodeError {
  CborCyclicError(this.cause);

  final Object cause;

  @override
  String toString() {
    return 'Cbor cyclic error';
  }
}
