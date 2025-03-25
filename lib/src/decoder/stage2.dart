/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

import 'stage1.dart';

class RawValueTagged {
  RawValueTagged(
    this.header, {
    this.data = const [],
    required this.offset,
    this.tags = const [],
  });

  final Header header;
  final List<int> data;
  final int offset;
  final List<int> tags;
}

class RawSinkTagged implements Sink<RawValue> {
  RawSinkTagged(this.sink);

  final Sink<RawValueTagged> sink;
  List<int> _tags = [];

  @override
  void add(RawValue data) {
    if (data.header.majorType == 6) {
      if (data.header.arg.isIndefiniteLength) {
        throw CborMalformedException('Tag can not have additional info 31');
      }

      _tags.add(data.header.arg.toInt());
    } else {
      sink.add(
        RawValueTagged(
          data.header,
          offset: data.start,
          data: data.data,
          tags: _clearTags(),
        ),
      );
    }
  }

  @override
  void close() {
    sink.close();
  }

  List<int> _clearTags() {
    final tags = _tags;
    _tags = [];
    return tags;
  }
}
