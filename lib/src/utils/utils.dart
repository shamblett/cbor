/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

extension IterableExt<T> on Iterable<T> {
  Iterable<List<T>> chunks(int length) sync* {
    final iterator = this.iterator;

    while (true) {
      final chunk = <T>[];
      for (var i = 0; i < length; i++) {
        if (!iterator.moveNext()) {
          return;
        }

        chunk.add(iterator.current);
      }

      yield chunk;
    }
  }
}

extension SinkExt<T> on Sink<T> {
  Sink<U> map<U>(T Function(U) conversion) => _MapSink<T, U>(conversion, this);
}

class _MapSink<T, U> extends Sink<U> {
  _MapSink(this.map, this.sink);

  final T Function(U) map;
  final Sink<T> sink;

  @override
  void add(U data) {
    sink.add(map(data));
  }

  @override
  void close() {
    sink.close();
  }
}

extension DateTimeExtension on DateTime {
  /// Will ommit milliseconds if it is 0.
  ///
  /// Will trim second fraction.
  ///
  /// Will add time zone.
  String toInternetIso8601String(Duration? timeZoneOffset) {
    var x = this;
    if (timeZoneOffset == null) {
      timeZoneOffset = x.timeZoneOffset;
      x = x.toUtc();
    }

    final String y;
    if (x.year.abs() < 9999) {
      final ySign = x.year < 0 ? '-' : '';
      y = ySign + x.year.abs().toString().padLeft(4, '0');
    } else {
      final ySign = x.year < 0 ? '-' : '+';
      y = ySign + x.year.abs().toString().padLeft(6, '0');
    }

    final m = x.month.toString().padLeft(2, '0');
    final d = x.day.toString().padLeft(2, '0');
    final h = x.hour.toString().padLeft(2, '0');
    final min = x.minute.toString().padLeft(2, '0');
    final sec = x.second.toString().padLeft(2, '0');

    final String secFraction;
    if (x.millisecond == 0) {
      secFraction = '';
    } else {
      final ms = x.millisecond.toString().padLeft(3, '0');
      final us =
          x.microsecond != 0 ? x.microsecond.toString().padLeft(3, '0') : '';
      secFraction = '.$ms$us'.replaceAll(RegExp('0*\$'), '');
    }

    final String timeZone;
    if (timeZoneOffset.inMinutes == 0) {
      timeZone = 'Z';
    } else {
      final timeZoneTotalMin = timeZoneOffset.inMinutes.abs();
      final timeZoneSign = !timeZoneOffset.isNegative ? '+' : '-';
      final timeZoneHour = (timeZoneTotalMin ~/ 60).toString().padLeft(2, '0');
      final timeZoneMin = (timeZoneTotalMin % 60).toString().padLeft(2, '0');

      timeZone = '$timeZoneSign$timeZoneHour:$timeZoneMin';
    }

    return '$y-$m-${d}T$h:$min:$sec$secFraction$timeZone';
  }
}

/// Returns whether T is a subtype of U.
bool isSubtype<T, U>() => _Helper<T>() is _Helper<U>;

class _Helper<T> {
  const _Helper();
}

bool isHintSubtype(int hint) {
  switch (hint) {
    case CborTag.dateTimeString:
    case CborTag.epochDateTime:
    case CborTag.positiveBignum:
    case CborTag.negativeBignum:
    case CborTag.bigFloat:
    case CborTag.encodedCborData:
    case CborTag.uri:
    case CborTag.base64Url:
    case CborTag.base64:
    case CborTag.regex:
    case CborTag.mime:
      return true;
  }

  return false;
}

bool isExpectConversion(int tag) {
  switch (tag) {
    case CborTag.expectedConversionToBase16:
    case CborTag.expectedConversionToBase64:
    case CborTag.expectedConversionToBase64Url:
      return true;
  }

  return false;
}
