/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('DateTime conversion tests', () {
    test('With 0 ms', () {
      expect(
        CborDateTimeString(DateTime.utc(2013, 3, 21, 20, 4, 0)).toString(),
        '2013-03-21T20:04:00Z',
      );
    });

    test('With 200 ms', () {
      expect(
        CborDateTimeString(DateTime.utc(2013, 3, 21, 20, 4, 0, 200)).toString(),
        '2013-03-21T20:04:00.2Z',
      );
    });

    test('With 200.5 ms', () {
      expect(
        CborDateTimeString(
          DateTime.utc(2013, 3, 21, 20, 4, 0, 200, 500),
        ).toString(),
        '2013-03-21T20:04:00.2005Z',
      );
    });

    test('With timezone', () {
      expect(
        CborDateTimeString(
          DateTime(2013, 3, 21, 20, 4, 0),
          timeZoneOffset: Duration(hours: 2, minutes: 30),
        ).toString(),
        '2013-03-21T20:04:00+02:30',
      );
    });
  });
}
