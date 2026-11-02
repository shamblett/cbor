/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:cbor/simple.dart' as simple;
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

    test('Local DateTime preserves its instant after encoding', () {
      final value = DateTime.fromMicrosecondsSinceEpoch(1793559660195927);
      final encoded = simple.cbor.encode({'t': value});
      final decoded = cborDecode(encoded) as CborMap;
      final timestamp = decoded[CborString('t')]! as CborDateTimeString;

      expect(timestamp.tags, [CborTag.dateTimeString]);
      expect(
        DateTime.parse(timestamp.toString()).microsecondsSinceEpoch,
        value.microsecondsSinceEpoch,
      );
    });

    test('Microseconds survive when milliseconds are zero', () {
      final value = DateTime.utc(2026, 11, 1, 19, 1, 0, 0, 927);
      final encoded = cborEncode(CborDateTimeString(value));
      final decoded = cborDecode(encoded) as CborDateTimeString;

      expect(decoded.toString(), '2026-11-01T19:01:00.000927Z');
      expect(
        decoded.toDateTime().microsecondsSinceEpoch,
        value.microsecondsSinceEpoch,
      );
    });

    test('DateTime encoding preserves local fields and fractional seconds', () {
      for (final month in [1, 7, 11]) {
        for (final fraction in [0, 1, 927, 1000, 195927, 999999]) {
          final utc = DateTime.utc(2026, month, 1, 19, 1, 0, 0, fraction);
          for (final value in [utc, utc.toLocal()]) {
            final decoded =
                cborDecode(simple.cbor.encode(value)) as CborDateTimeString;
            final timestamp = decoded.toString();
            final parsed = DateTime.parse(timestamp);

            expect(decoded.tags, [CborTag.dateTimeString]);
            expect(parsed.microsecondsSinceEpoch, value.microsecondsSinceEpoch);
            expect(
              timestamp.substring(0, 19),
              value.toIso8601String().substring(0, 19),
            );
          }
        }
      }
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
