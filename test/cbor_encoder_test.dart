/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';

void main() {
  group('RFC Appendix A Diagnostics encoder tests -> ', () {
    // Common initialisation
    final cbor.OutputDynamic output = new cbor.OutputDynamic();
    final cbor.Encoder encoder = new cbor.Encoder(output);

    test('0', () {
      output.clear();
      encoder.writeInt(0);
      expect(output.getDataAsList(), [0x00]);
    });

    test('1', () {
      output.clear();
      encoder.writeInt(1);
      expect(output.getDataAsList(), [0x01]);
    });

    test('10', () {
      output.clear();
      encoder.writeInt(10);
      expect(output.getDataAsList(), [0x0a]);
    });

    test('23', () {
      output.clear();
      encoder.writeInt(23);
      expect(output.getDataAsList(), [0x17]);
    });

    test('24', () {
      output.clear();
      encoder.writeInt(24);
      expect(output.getDataAsList(), [0x18, 0x18]);
    });

    test('25', () {
      output.clear();
      encoder.writeInt(25);
      expect(output.getDataAsList(), [0x18, 0x19]);
    });

    test('100', () {
      output.clear();
      encoder.writeInt(100);
      expect(output.getDataAsList(), [0x18, 0x64]);
    });

    test('1000', () {
      output.clear();
      encoder.writeInt(1000);
      expect(output.getDataAsList(), [0x19, 0x03, 0xe8]);
    });

    test('1000000', () {
      output.clear();
      encoder.writeInt(1000000);
      expect(output.getDataAsList(), [0x1a, 0x00, 0x0f, 0x42, 0x40]);
    });

    test('1000000000000', () {
      output.clear();
      encoder.writeInt(1000000000000);
      expect(output.getDataAsList(),
          [0x1b, 0x00, 0x00, 0x00, 0xe8, 0xd4, 0xa5, 0x10, 0x00]);
    });

    test('18446744073709551615', () {
      output.clear();
      encoder.writeInt(18446744073709551615);
      expect(output.getDataAsList(),
          [0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
    });

    test('18446744073709551616', () {
      output.clear();
      encoder.writeInt(18446744073709551616);
      expect(output.getDataAsList(),
          [0xc2, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00
          ]);
    });
  });
}
