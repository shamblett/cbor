/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */
import 'package:typed_data/typed_data.dart' as typed;
import 'package:cbor/cbor.dart' as cbor;
import 'package:test/test.dart';
import 'cbor_test_listener.dart';

void main() {
  group('Original C++ tests', () {
    test('Encode/Decode confidence -> ', () {
      // Encoding
      final cbor.OutputDynamic output = new cbor.OutputDynamic();
      final cbor.Encoder encoder = new cbor.Encoder(output);
      encoder.writeArray(9);
      encoder.writeInt(123);
      encoder.writeInt(-457);
      encoder.writeString("barrr");
      encoder.writeInt(321);
      encoder.writeInt(322);
      encoder.writeString("foo");
      encoder.writeBool(true);
      encoder.writeBool(false);
      encoder.writeNull();
      encoder.writeUndefined();

      // Decoding
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.ListenerDebug listener = new cbor.ListenerDebug();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
    });
  });

  group('RFC Diagnostics decoder tests -> ', () {
    // Common initialisation
    final cbor.OutputDynamic output = new cbor.OutputDynamic();
    final ListenerTest listener = new ListenerTest();

    test('0', () {
      output.clear();
      final List<int> values = [0x0];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 0);
    });

    test('1', () {
      output.clear();
      final List<int> values = [0x1];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 1);
    });

    test('10', () {
      output.clear();
      final List<int> values = [0x0a];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 10);
    });

    test('23', () {
      output.clear();
      final List<int> values = [0x17];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 23);
    });

    test('24', () {
      output.clear();
      final List<int> values = [0x18, 0x18];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 24);
    });

    test('25', () {
      output.clear();
      final List<int> values = [0x18, 0x19];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 25);
    });

    test('100', () {
      output.clear();
      final List<int> values = [0x18, 0x64];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 100);
    });

    test('1000', () {
      output.clear();
      final List<int> values = [0x19, 0x03, 0xe8];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 1000);
    });

    test('1000000', () {
      output.clear();
      final List<int> values = [0x1a, 0x00, 0x0f, 0x42, 0x40];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 1000000);
    });

    test('1000000000000', () {
      output.clear();
      final List<int> values = [
        0x1b,
        0x00,
        0x00,
        0x00,
        0xe8,
        0xd4,
        0xa5,
        0x10,
        0x00
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 1000000000000);
    });

    test('18446744073709551615', () {
      output.clear();
      final List<int> values = [
        0x1b,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 18446744073709551615);
    });

    test('18446744073709551616', () {
      output.clear();
      final List<int> values = [
        0xc2,
        0x49,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue.toString(), "[1, 0, 0, 0, 0, 0, 0, 0, 0]");
      expect(listener.lastTag, 2);
      expect(listener.lastByteCount, 9);
    });

    test('-18446744073709551616', () {
      output.clear();
      final List<int> values = [
        0x3b,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -18446744073709551616);
    });

    test('18446744073709551617', () {
      output.clear();
      final List<int> values = [
        0xc3,
        0x49,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final ListenerTest listener = new ListenerTest();
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue.toString(), "[1, 0, 0, 0, 0, 0, 0, 0, 0]");
      expect(listener.lastTag, 3);
      expect(listener.lastByteCount, 9);
    });

    test('-1', () {
      output.clear();
      final List<int> values = [0x20];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -1);
    });

    test('-10', () {
      output.clear();
      final List<int> values = [0x29];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -10);
    });

    test('-100', () {
      output.clear();
      final List<int> values = [0x38, 0x63];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -100);
    });

    test('-1000', () {
      output.clear();
      final List<int> values = [0x39, 0x3, 0xe7];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -1000);
    });

    test('0.0', () {
      output.clear();
      final List<int> values = [0xf9, 0x00, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 0.0);
    });

    test('-0.0', () {
      output.clear();
      final List<int> values = [0xf9, 0x80, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, -0.0);
    });

    test('1.0', () {
      output.clear();
      final List<int> values = [0xf9, 0x3c, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, 1.0);
    });
  });
}
