/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

library cbor;

import 'dart:convert' as convertor;
import 'dart:typed_data';
import 'dart:math';
import 'dart:collection';
import 'package:typed_data/typed_data.dart' as typed;

/// The CBOR package exported interface

part 'src/cbor.dart';

part 'src/cbor_listener_stack.dart';
part 'src/cbor_item_stack.dart';
part 'src/cbor_float_support.dart';
part 'src/cbor_constants.dart';
part 'src/cbor_output.dart';
part 'src/cbor_input.dart';
part 'src/cbor_decoder.dart';
part 'src/cbor_encoder.dart';
part 'src/cbor_listener_debug.dart';
part 'src/cbor_listener.dart';

part 'src/cbor_dart_item.dart';
part 'src/cbor_output_standard.dart';

/// Float encoding directives
enum encodeFloatAs {
  half,
  single,
  double
}

