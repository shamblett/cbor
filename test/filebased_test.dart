/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
@TestOn('vm')
import 'dart:io';

import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  final currDir = Directory.current.path;

  group('File based decoding', () {
    test('Floats -> ', () async {
      final f = File('$currDir/test/data/floats.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(
        decoded,
        CborMap({
          CborString('half'): CborFloat(0.0),
          CborString('single'): CborFloat(3.4028234663852886e+38),
          CborString('simple values'): CborList([
            CborBool(true),
            CborBool(false),
            CborNull(),
          ]),
        }),
      );
    });

    test('Indefinitite string -> ', () async {
      final f = File('$currDir/test/data/indef_string.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(decoded, CborString('Helloworld!'));
    });

    test('Integer -> ', () async {
      final f = File('$currDir/test/data/integer.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(decoded, CborSmallInt(42));
    });

    test('Map -> ', () async {
      final f = File('$currDir/test/data/map.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(
        decoded,
        CborMap({
          CborString('a key'): CborBool(false),
          CborString('a secret key'): CborString('42'),
          CborSmallInt(0): CborSmallInt(-1),
        }),
      );
    });

    test('Nested array -> ', () async {
      final f = File('$currDir/test/data/nested_array.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(
        decoded,
        CborList([
          CborSmallInt(1),
          CborSmallInt(2),
          CborList([
            CborSmallInt(3),
            CborList([
              CborSmallInt(4),
              CborSmallInt(5),
              CborList([]),
            ]),
          ]),
        ]),
      );
    });

    test('Tagged date -> ', () async {
      final f = File('$currDir/test/data/tagged_date.cbor');
      final decoded = await f.openRead().transform(cbor.decoder).single;
      expect(decoded, CborDateTimeString.fromString('2013-03-21T20:04:00Z'));
    });
  });

  group('File based encoding', () {
    test('Floats -> ', () async {
      final cmp = File('$currDir/test/data/floats.cbor');
      final f = File('$currDir/test/data/floats.out');
      final write = f.openWrite();
      cbor.encoder.startChunkedConversion(write).add(CborMap({
            CborString('half'): CborFloat(0.0),
            CborString('single'): CborFloat(3.4028234663852886e+38),
            CborString('simple values'): CborList([
              CborBool(true),
              CborBool(false),
              CborNull(),
            ]),
          }));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });

    test('Indefinitite string -> ', () async {
      final cmp = File('$currDir/test/data/indef_string.cbor');
      final f = File('$currDir/test/data/indef_string.out');
      final write = f.openWrite();
      cbor.encoder
          .startChunkedConversion(write)
          .add(CborEncodeIndefiniteLengthString(['Hello', 'world!']));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });

    test('Integer -> ', () async {
      final cmp = File('$currDir/test/data/integer.cbor');
      final f = File('$currDir/test/data/integer.out');
      final write = f.openWrite();
      cbor.encoder.startChunkedConversion(write).add(CborSmallInt(42));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });

    test('Map -> ', () async {
      final cmp = File('$currDir/test/data/map.cbor');
      final f = File('$currDir/test/data/map.out');
      final write = f.openWrite();
      cbor.encoder.startChunkedConversion(write).add(CborMap({
            CborString('a key'): CborBool(false),
            CborString('a secret key'): CborString('42'),
            CborSmallInt(0): CborSmallInt(-1),
          }));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });

    test('Nested array -> ', () async {
      final cmp = File('$currDir/test/data/nested_array.cbor');
      final f = File('$currDir/test/data/nested_array.out');
      final write = f.openWrite();
      cbor.encoder.startChunkedConversion(write).add(CborList([
            CborSmallInt(1),
            CborSmallInt(2),
            CborList([
              CborSmallInt(3),
              CborList([
                CborSmallInt(4),
                CborSmallInt(5),
                CborList([]),
              ]),
            ]),
          ]));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });

    test('Tagged date -> ', () async {
      final cmp = File('$currDir/test/data/tagged_date.cbor');
      final f = File('$currDir/test/data/tagged_date.out');
      final write = f.openWrite();
      cbor.encoder
          .startChunkedConversion(write)
          .add(CborDateTimeString.fromString('2013-03-21T20:04:00Z'));
      await write.flush();
      expect(await f.readAsBytes(), await cmp.readAsBytes());
    });
  });
}
