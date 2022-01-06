/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

/// This API exposes [CborSimpleCodec], which allows converting from CBOR
/// to Dart objects without `CborValue`.
///
/// Everything this API exposes, except the [cbor] constant, is exposed
/// from the advanced API too.
library simple;

import 'src/simple.dart';

export 'src/simple.dart';

/// A constant instance of [CborSimpleCodec].
const CborSimpleCodec cbor = CborSimpleCodec();
