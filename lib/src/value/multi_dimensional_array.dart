/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 17/01/2026
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/internal.dart';

import '../encoder/sink.dart';
import '../utils/arg.dart';

/// A CBOR Multi-dimensional Array (RFC 8746).
class CborMultiDimensionalArray with CborValueMixin implements CborValue {
  final List<int> dimensions;
  final CborValue data;
  @override
  final List<int> tags;

  const CborMultiDimensionalArray({
    required this.dimensions,
    required this.data,
    this.tags = const [CborTag.multiDimensionalArray],
  });

  factory CborMultiDimensionalArray.fromTypedArray(
    List<int> dimensions,
    CborTypedArray data, {
    List<int>? tags,
  }) {
    return CborMultiDimensionalArray(
      dimensions: dimensions,
      data: data,
      tags: tags ?? [CborTag.multiDimensionalArray],
    );
  }

  factory CborMultiDimensionalArray.fromValues(
    List<int> dimensions,
    List<CborValue> values, {
    List<int>? tags,
  }) {
    return CborMultiDimensionalArray(
      dimensions: dimensions,
      data: CborList(values),
      tags: tags ?? [CborTag.multiDimensionalArray],
    );
  }

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    // Array of length 2
    sink.addHeaderInfo(CborMajorType.array, Arg.int(2));

    // Dimensions array
    sink.addHeaderInfo(CborMajorType.array, Arg.int(dimensions.length));
    for (final dim in dimensions) {
      if (dim < 0) {
        sink.addHeaderInfo(CborMajorType.nint, Arg.int(-1 - dim));
      } else {
        sink.addHeaderInfo(CborMajorType.uint, Arg.int(dim));
      }
    }

    // Data
    data.encode(sink);
  }

  @override
  Object? toObjectInternal(Set<Object> cyclicCheck, ToObjectOptions o) {
    return [dimensions, data.toObjectInternal(cyclicCheck, o)];
  }

  @override
  Object? toJsonInternal(Set<Object> cyclicCheck, ToJsonOptions o) {
    return [dimensions, data.toJsonInternal(cyclicCheck, o)];
  }
}
