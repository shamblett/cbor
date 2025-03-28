/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'dart:convert';

import 'package:ieee754/ieee754.dart';

import 'stage1.dart';
import '../constants.dart';
import '../value/value.dart';

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
  int indent = CborConstants.prettyPrintIndent,
}) {
  final prettyPrint = _PrettyPrint(input, indent: indent);
  RawSink(prettyPrint)
    ..add(input)
    ..close();

  return prettyPrint.writer.toString();
}

class _PrettyPrint implements Sink<RawValue> {
  final StringBuffer writer = StringBuffer();
  final List<int> data;
  final List<_Nesting> nested = [];
  final int indent;

  _PrettyPrint(this.data, {required this.indent});

  @override
  void close() {
    return;
  }

  @override
  void add(RawValue x) {
    final indentation = ' ' * indent * nested.length;

    writer.write(indentation);
    writer.writeAll(
      data
          .getRange(x.start, x.end)
          .map((by) => '${by.toRadixString(CborConstants.hexRadix)} '),
    );

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
      case CborMajorType.uint:
        writer.write('(int ${x.header.arg.toBigInt()})');
        break;
      case CborMajorType.nint:
        writer.write('(int ${~x.header.arg.toBigInt()})');
        break;
      case CborMajorType.byteString:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length bytes)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(bytes)');
        }
        break;
      case CborMajorType.textString:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length string)');
          nested.add(_Nesting(null));
        } else {
          writer.write(
            '(string "${(const Utf8Codec(allowMalformed: true)).decode(x.data)}")',
          );
        }
        break;
      case CborMajorType.array:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length array)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(array length ${length.toInt()})');
          nested.add(_Nesting(length.toInt()));
        }
        break;
      case CborMajorType.map:
        final length = x.header.arg;
        if (length.isIndefiniteLength) {
          writer.write('(indefinite length map)');
          nested.add(_Nesting(null));
        } else {
          writer.write('(map length ${length.toInt()})');
          nested.add(
            _Nesting(length.toInt() * CborConstants.prettyPrintIndent),
          );
        }
        break;
      case CborMajorType.tag:
        writer.write('(tag ${x.header.arg.toInt()})');
        break;
      case CborMajorType.simpleFloat:
        switch (x.header.additionalInfo) {
          case CborAdditionalInfo.simpleFalse:
            writer.write('(false)');
            break;
          case CborAdditionalInfo.simpleTrue:
            writer.write('(true)');
            break;
          case CborAdditionalInfo.simpleNull:
            writer.write('(null)');
            break;
          case CborAdditionalInfo.simpleUndefined:
            writer.write('(undefined)');
            break;
          case CborAdditionalInfo.halfPrecisionFloat:
            writer.write(
              '(${FloatParts.fromFloat16Bytes(x.header.dataBytes).toDouble()})',
            );
            break;
          case CborAdditionalInfo.singlePrecisionFloat:
            writer.write(
              '(${FloatParts.fromFloat32Bytes(x.header.dataBytes).toDouble()})',
            );
            break;
          case CborAdditionalInfo.doublePrecisionFloat:
            writer.write(
              '(${FloatParts.fromFloat64Bytes(x.header.dataBytes).toDouble()})',
            );
            break;
          case CborAdditionalInfo.breakStop:
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
  int? remainingItems;

  _Nesting(this.remainingItems);
}
