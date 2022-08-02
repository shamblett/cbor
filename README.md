# cbor 
[![Build Status](https://github.com/shamblett/cbor/actions/workflows/ci.yml/badge.svg)](https://github.com/shamblett/cbor/actions/workflows/ci.yml)
[![Pub Version](https://shields.io/pub/v/cbor)](https://pub.dev/packages/cbor)

[Documentation](https://pub.dev/documentation/cbor/latest/)

This package provides an encoding/decoding package for the Concise Binary Object
Representation as documented in [RFC8949](https://www.rfc-editor.org/rfc/rfc8949.html).

CBOR is increasingly used as a line protocol in the IOT world where the overhead
of transmitting JSON on constrained devices can be large in packet size and
processing overheads.

## Features

* Streamlined encoding and decoding of CBOR, including indefinite length and
  streamed decoding.
* Set of types that semantically handles types, nesting, and tags.
* Automatic conversion for the smallest size needed for integers.
* Automatic conversion for the smallest precision needed for floating point
  numbers.
* Any value can be the key for a map.
* Optional simple API for encoding and decoding directly to Dart objects.
* Pretty-printing and conversion to JSON.

## Usage

Two APIs are provided, `cbor.dart` and `simple.dart`.

### `cbor.dart`

Encodes from `CborValue` and decodes to `CborValue`.

The `CborValue` contains the tags for this item, and its subtypes are used to
identify the type and tags for the item. This allows one to handle information
encoded in a more lossless way.

Inheritance tree for `CborValue` looks something like this:

```
CborValue
├── CborInt
│   ├── CborSmallInt
│   └── CborDateTimeInt
├── CborBytes
│   └── CborBigInt
├── CborString
│   ├── CborDateTimeString
│   ├── CborBase64
│   ├── CborBase64Url
│   ├── CborMime
│   └── CborRegex
├── CborFloat
│   └── CborDateTimeFloat
├── CborSimpleValue
│   ├── CborNull
│   ├── CborBool
│   └── CborUndefined
├── CborMap
└── CborList
    ├── CborDecimalFraction
    └── CborBigFloat
```

#### Example

```dart
import 'package:cbor/cbor.dart';

test('{1:2,3:4}', () {
   final encoded = cbor.encode(CborMap({
      CborSmallInt(1): CborSmallInt(2),
      CborSmallInt(3): CborSmallInt(4),
   }));
   expect(encoded, [0xa2, 0x01, 0x02, 0x03, 0x04]);
});
```

[Check out the example folder for more examples](https://github.com/shamblett/cbor/tree/master/example).

### `simple.dart`

Less powerful, but may be the best option for simple applications that do not
need any of the fancy features of the `cbor` API above.

The encoder in simple API will operate similarly to constructing a `CborValue`
from the input and the encoding it.

Decoder will translate the input to a common Dart object, ignoring any extra
tags after the type is decided.

#### Example

```dart
import 'package:cbor/simple.dart';

test('{1:2,3:4}', () {
   final encoded = cbor.encode({
      1: 2,
      3: 4,
   });
   expect(encoded, [0xa2, 0x01, 0x02, 0x03, 0x04]);
});
```
