/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:ieee754/ieee754.dart';

import 'stage1.dart';

/// Pretty print a CBOR input.
///
/// Example output with `indent = 2` for `{1: "one", 2: "two"}`:
///
/// ```txt
/// a2 (map length 2)
///   1 (int 1)
///   63 6f 6e 65 (string "one")
///   2 (int 2)
///   63 74 77 6f (string "two")
/// ```
String cborPrettyPrint(
  List<int> input, {
  int indent = 2,
}) {
  final prettyPrint = _PrettyPrint(input, indent: indent);
  RawSink(prettyPrint)
    ..add(input)
    ..close();

  return prettyPrint.writer.toString();
}

class _PrettyPrint extends Sink<RawValue> {
  _PrettyPrint(
    this.data, {
    required this.indent,
  });

  final StringBuffer writer = StringBuffer();
  final List<int> data;
  final List<_Nesting> nested = [];
  final int indent;

  @override
  void close() {}

  @override
  void add(RawValue x) {
    final indentation = ' ' * indent * nested.length;

    writer.write(indentation);
    writer.writeAll(
        data.getRange(x.start, x.end).map((by) => '${by.toRadixString(16)} '));

    if (nested.isNotEmpty) {
      var remainingItems = nested.last.remainingItems;
      if (remainingItems != null) {
        remainingItems -= 1;
        nested.last.remainingItems = remainingItems;

        if (remainingItems <= 0) {
          nested.removeLast();
        }
      }
    }

    switch (x.header.majorType) {
      case 0:
        writer.write('(int ${x.header.arg.toBigInt()})');
        break;
      case 1:
        writer.write('(int ${~x.header.arg.toBigInt()})');
        break;
      case 2:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length bytes)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(bytes)');
        }
        break;
      case 3:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length string)');
          nested.add(_Nesting(null));
        } else {
          writer.write(
              '(string "${(const Utf8Codec(allowMalformed: true)).decode(x.data)}")');
        }
        break;
      case 4:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length array)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(array length ${length.toInt()})');
          nested.add(_Nesting(length.toInt()));
        }
        break;
      case 5:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length map)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(map length ${length.toInt()})');
          nested.add(_Nesting(length.toInt() * 2));
        }
        break;
      case 6:
        writer.write('(tag ${x.header.arg.toInt()})');
        break;
      case 7:
        switch (x.header.additionalInfo) {
          case 20:
            writer.write('(false)');
            break;
          case 21:
            writer.write('(true)');
            break;
          case 22:
            writer.write('(null)');
            break;
          case 23:
            writer.write('(undefined)');
            break;
          case 25:
            writer.write(
                '(${FloatParts.fromFloat16Bytes(x.header.dataBytes).toDouble()})');
            break;
          case 26:
            writer.write(
                '(${FloatParts.fromFloat32Bytes(x.header.dataBytes).toDouble()})');
            break;
          case 27:
            writer.write(
                '(${FloatParts.fromFloat64Bytes(x.header.dataBytes).toDouble()})');
            break;
          case 31:
            writer.write('(break)');
            nested.removeLast();
            break;

          default:
            writer.write('(simple ${x.header.arg.toInt()})');
            break;
        }
    }

    writer.write('\n');
  }
}

class _Nesting {
  _Nesting(this.remainingItems);

  int? remainingItems;
}
