/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';

import '../constants.dart';

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

class _MapSink<T, U> implements Sink<U> {
  final T Function(U) map;
  final Sink<T> sink;

  _MapSink(this.map, this.sink);

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
    if (x.year.abs() < CborConstants.maxYear) {
      final ySign = x.year < 0 ? '-' : '';
      y = ySign + x.year.abs().toString().padLeft(CborConstants.four, '0');
    } else {
      final ySign = x.year < 0 ? '-' : '+';
      y = ySign + x.year.abs().toString().padLeft(CborConstants.six, '0');
    }

    final m = x.month.toString().padLeft(CborConstants.two, '0');
    final d = x.day.toString().padLeft(CborConstants.two, '0');
    final h = x.hour.toString().padLeft(CborConstants.two, '0');
    final min = x.minute.toString().padLeft(CborConstants.two, '0');
    final sec = x.second.toString().padLeft(CborConstants.two, '0');

    final String secFraction;
    if (x.millisecond == 0) {
      secFraction = '';
    } else {
      final ms = x.millisecond.toString().padLeft(CborConstants.three, '0');
      final us =
          x.microsecond != 0
              ? x.microsecond.toString().padLeft(CborConstants.three, '0')
              : '';
      secFraction = '.$ms$us'.replaceAll(RegExp('0*\$'), '');
    }

    final String timeZone;
    if (timeZoneOffset.inMinutes == 0) {
      timeZone = 'Z';
    } else {
      final timeZoneTotalMin = timeZoneOffset.inMinutes.abs();
      final timeZoneSign = !timeZoneOffset.isNegative ? '+' : '-';
      final timeZoneHour = (timeZoneTotalMin ~/ CborConstants.seconds)
          .toString()
          .padLeft(CborConstants.two, '0');
      final timeZoneMin = (timeZoneTotalMin % CborConstants.seconds)
          .toString()
          .padLeft(CborConstants.two, '0');

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
    case CborTag.decimalFraction:
    case CborTag.bigFloat:
    case CborTag.encodedCborData:
    case CborTag.rationalNumber:
    case CborTag.uri:
    case CborTag.base64Url:
    case CborTag.base64:
    case CborTag.regex:
    case CborTag.mime:
    case CborTag.multiDimensionalArray:
    case CborTag.uint8Array:
    case CborTag.uint16ArrayBE:
    case CborTag.uint32ArrayBE:
    case CborTag.uint64ArrayBE:
    case CborTag.uint8ArrayClamped:
    case CborTag.uint16ArrayLE:
    case CborTag.uint32ArrayLE:
    case CborTag.uint64ArrayLE:
    case CborTag.sint8Array:
    case CborTag.sint16ArrayBE:
    case CborTag.sint32ArrayBE:
    case CborTag.sint64ArrayBE:
    case CborTag.sint16ArrayLE:
    case CborTag.sint32ArrayLE:
    case CborTag.sint64ArrayLE:
    case CborTag.float16ArrayBE:
    case CborTag.float32ArrayBE:
    case CborTag.float64ArrayBE:
    case CborTag.float128ArrayBE:
    case CborTag.float16ArrayLE:
    case CborTag.float32ArrayLE:
    case CborTag.float64ArrayLE:
    case CborTag.float128ArrayLE:
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
