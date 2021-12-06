/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

// How the decoder works:
//
// Data in form of bytes is inserted into `Reader`.
//
// The `Reader` then supplies a `Header` to a `BuilderReader`, which will
// return a `Builder` when the `Header` is supplied.
//
// Then, the `Builder` can `poll` to read bytes, and when enough bytes are
// read it will return a `CborValue` - a list or map builder will contain
// builders inside themselves to build their items.
//
// At any point, if the `Reader` has not enough bytes, `null` is returned.
// The builder can store state about the previous bytes to allow
// streamed decoding. In special, a list or map can store the items which
// have been built so far.

import 'dart:convert';

import 'package:cbor/cbor.dart';

import 'builder.dart';

// TODO
//
// For strict mode, reject
//
// a map (major type 5) that has more than one entry with the same
// key
//
// a tag that is used on a data item of the incorrect type

/// A CBOR decoder.
///
/// The CBOR decoder will always throw [FormatException] when:
///
/// * An invalid value for additional info is provided.
///
/// This will happen regardless of being in [strict] mode because without
/// knowing the additional info, one cannot know the length of the item, and
/// therefore cannot parse the input from this point forwards.
///
/// If the CBOR decoder is using [strict] mode, it will throw [FormatException]
/// when:
///
/// * The input does not encode a single and only a single CBOR value, or
/// * A CBOR `break` is encountered outside a indefinite length item, or
/// * An indefinite byte string or string contains any item other than
///   a definite length byte string or string, respectively, or
/// * A value with major type `7` and invalid additional info is provided.
///
/// When not in [strict] mode, these errors will be ignored.
class CborDecoder extends Converter<List<int>, CborValue> {
  /// Create a CBOR decoder.
  ///
  /// Currently strict mode is on by default, but this may change in the
  /// future. If you want to rely on this, explicitly add the argument.
  const CborDecoder({this.strict = true});

  /// If `true`, we are in strict mode. Check [CborDecoder] for its meaning.
  final bool strict;

  @override
  Stream<CborValue> bind(Stream<List<int>> input) async* {
    final reader = BuilderReader(strict);
    var yielded = false;
    Builder? builder;

    await for (final data in input) {
      if (strict && yielded) {
        throw FormatException('Expected at most one CBOR value.');
      }

      reader.add(data);
      builder ??= reader.read();
      final value = builder?.poll();
      if (value != null) {
        yield value;
        if (!strict) {
          return;
        }

        if (reader.remaniningBytes != 0) {
          throw FormatException('Expected at most one CBOR value.');
        }

        yielded = true;
      }
    }

    if (strict && !yielded) {
      throw FormatException('Expected at least one CBOR value.');
    }
  }

  @override
  CborValue convert(List<int> input) {
    final reader = BuilderReader(strict);

    reader.add(input);
    final value = reader.read()?.poll();

    if (value == null) {
      if (!strict) {
        return const CborNull();
      } else {
        throw FormatException('Expected at least one CBOR value.');
      }
    }

    if (strict && reader.remaniningBytes != 0) {
      throw FormatException('Expected at most one CBOR value.');
    }

    return value;
  }
}
