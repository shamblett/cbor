/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

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

class RawSinkTagged extends Sink<RawValue> {
  RawSinkTagged(this.sink);

  final Sink<RawValueTagged> sink;
  List<int> _tags = [];

  @override
  void add(RawValue data) {
    if (data.header.majorType == 6) {
      _tags.add(data.header.info.toInt());
    } else {
      sink.add(RawValueTagged(
        data.header,
        offset: data.start,
        data: data.data,
        tags: _clearTags(),
      ));
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
