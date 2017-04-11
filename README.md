# cbor

A CBOR library for Dart developers.

This package provides an 
encoding/decoding package for the Concise 
Binary Object Representation as documented in RFC7049.

CBOR is increasingly used as a line protocol in the IOT
world where the overhead of transmitting JSON on constrained devices can be large
in packet size and processing overheads.

The Cbor package provides an RFC7049 compliant solution for both the encoding and decoding of CBOR data.

The test suite supports the encoding and decoding examples in Appendix A of RFC7049 amongst others. Specifically :-

1. Half, Single and Double precision floats are supported.
2. Tag based encoding is supported(table 3 of the RFC).
3. Indefinite item encoding/decoding is supported.
4. Items can be nested to any level.
5. All Major tag types are supported.
6. Smallest size first is used, i.e. if an int can be encoded in one byte then
   this size is used, similarly a double will be encoded into its smallest precision
   size(unless you specify otherwise);
   
The implementation of maps restricts map keys to be of either string or integer type, note
however that at the moment decoding to JSON will fail if map keys are not strings.

Please examine the files in the examples directory for usage examples and the
API docs for greater detail.

In general the package guarantees to decode what it encodes and should
decode all well formed CBOR data. Decoded output takes the form of standard Dart types, i.e.
floats become doubles, text become String, arrays become Lists etc.
This allows a simple interface for encoding from the Dart world and a simple interface to Dart world from the decoder.

Currently the package supports a payload based decoding, i.e. a complete CBOR entity needs to be submitted to the decoder. 
Streamed decoding may be supported in future versions.
Also error handling is somewhat basic, very badly formed CBOR data may
trigger exceptions in the decoding process, if you need to
protect against this please enclose all decoding operations in try/catch blocks. If you use this package at both ends of your CBOR interchange nodes you will not need
to do this.





