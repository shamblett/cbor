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
  group('RFC Appendix A Diagnostics decoder tests -> ', () {
    // Common initialisation
    final cbor.OutputStandard output = new cbor.OutputStandard();
    final ListenerTest listener = new ListenerTest();
    final cbor.ListenerStack slistener = new cbor.ListenerStack();

    test('0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x0];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [0]);
      decoder.setListener(slistener);
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 0);
    });

    test('1', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x1];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1);
    });

    test('10', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x0a];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [10]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 10);
    });

    test('23', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x17];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [23]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 23);
    });

    test('24', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x18, 0x18];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [24]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 24);
    });

    test('25', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x18, 0x19];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [25]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 25);
    });

    test('100', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x18, 0x64];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [100]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 100);
    });

    test('1000', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x19, 0x03, 0xe8];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1000]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1000);
    });

    test('1000000', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x1a, 0x00, 0x0f, 0x42, 0x40];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      slistener.stack.clear();
      expect(listener.lastValue, [1000000]);
      decoder.setListener(slistener);
      input.reset();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1000000);
    });

    test('1000000000000', () {
      output.clear();
      listener.clear();
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1000000000000]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1000000000000);

    });

    test('18446744073709551615', () {
      output.clear();
      listener.clear();
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [18446744073709551615]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 18446744073709551615);
    });

    test('18446744073709551616', () {
      output.clear();
      listener.clear();
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        2,
        [1, 0, 0, 0, 0, 0, 0, 0, 0]
      ]);
      expect(listener.lastTag, 2);
      expect(listener.lastByteCount, 9);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 18446744073709551616);
    });

    test('-18446744073709551616', () {
      output.clear();
      listener.clear();
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-18446744073709551616]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -18446744073709551616);
    });

    test('18446744073709551617', () {
      output.clear();
      listener.clear();
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        3,
        [1, 0, 0, 0, 0, 0, 0, 0, 0]
      ]);
      expect(listener.lastTag, 3);
      expect(listener.lastByteCount, 9);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 18446744073709551617);
    });

    test('-1', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x20];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-1]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -1);
    });

    test('-10', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x29];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-10]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -10);
    });

    test('-100', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x38, 0x63];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-100]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -100);
    });

    test('-1000', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x39, 0x3, 0xe7];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-1000]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -1000);
    });

    test('0.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x00, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [0.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 0.0);
    });

    test('-0.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x80, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-0.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -0.0);
    });

    test('1.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x3c, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1.0);
    });

    test('1.1', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0x3f,
        0xf1,
        0x99,
        0x99,
        0x99,
        0x99,
        0x99,
        0x9a
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1.1]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1.1);
    });

    test('1.5', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x3e, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1.5]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1.5);
    });

    test('65504.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x7b, 0xff];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [65504.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 65504.0);
    });

    test('100000.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xfa, 0x47, 0xc3, 0x50, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [100000.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 100000.0);
    });

    test('3.4028234663852886e+38', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xfa, 0x7f, 0x7f, 0xff, 0xff];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [3.4028234663852886e+38]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 3.4028234663852886e+38);
    });

    test('1.0e+300', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0x7e,
        0x37,
        0xe4,
        0x3c,
        0x88,
        0x00,
        0x75,
        0x9c
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1.0e+300]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1.0e+300);
    });

    test('5.960464477539063e-8', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x00, 0x01];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [5.960464477539063e-8]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 5.960464477539063e-8);
    });

    test('0.00006103515625', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x04, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [0.00006103515625]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 0.00006103515625);
    });

    test('-4.0', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0xc4, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-4.0]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -4.0);
    });

    test('-4.1', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0xc0,
        0x10,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66,
        0x66
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-4.1]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -4.1);
    });

    test('Infinity half', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x7c, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [double.INFINITY]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], double.INFINITY);
    });

    test('NaN half', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0x7e, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue[0], isNaN);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], isNaN);
    });

    test('-Infinity half', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf9, 0xfc, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-(double.INFINITY)]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -(double.INFINITY));
    });

    test('Infinity single', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xfa, 0x7f, 0x80, 0x00, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [double.INFINITY]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], double.INFINITY);
    });

    test('NaN single', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xfa, 0x7f, 0xc0, 0x00, 0x00];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue[0], isNaN);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], isNaN);
    });

    test('-Infinity single', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfa,
        0xff,
        0x80,
        0x00,
        0x00,
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-(double.INFINITY)]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -(double.INFINITY));
    });

    test('Infinity double', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0x7f,
        0xf0,
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [double.INFINITY]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], double.INFINITY);
    });

    test('NaN double', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0x7f,
        0xf8,
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue[0], isNaN);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], isNaN);
    });

    test('-Infinity double', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xfb,
        0xff,
        0xf0,
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
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [-(double.INFINITY)]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], -(double.INFINITY));
    });

    test('false', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf4];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [false]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], false);
    });

    test('true', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf5];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [true]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], true);
    });

    test('null', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf6];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue[0], isNull);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], null);
    });

    test('undefined', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf7];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["Undefined"]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], null);
    });

    test('Simple(16)', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf0];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [16]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 16);
    });

    test('Simple(24)', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf8, 0x18];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [24]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 24);
    });

    test('Simple(255)', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xf8, 0xff];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [255]);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 255);
    });

    test('Tag (0) Date Time', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xc0,
        0x74,
        0x32,
        0x30,
        0x31,
        0x33,
        0x2d,
        0x30,
        0x33,
        0x2d,
        0x32,
        0x31,
        0x54,
        0x32,
        0x30,
        0x3a,
        0x30,
        0x34,
        0x3a,
        0x30,
        0x30,
        0x5a
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [0, "2013-03-21T20:04:00Z"]);
      expect(listener.lastTag, 0);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], "2013-03-21T20:04:00Z");
    });

    test('Tag (1) Int', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xc1, 0x1a, 0x51, 0x4b, 0x67, 0xb0];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 1363896240]);
      expect(listener.lastTag, 1);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1363896240);
    });

    test('Tag (1) Float', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xc1,
        0xfb,
        0x41,
        0xd4,
        0x52,
        0xd9,
        0xec,
        0x20,
        0x00,
        0x00
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 1363896240.5]);
      expect(listener.lastTag, 1);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], 1363896240.5);
    });

    test('Tag (23) multiple', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xd7, 0x44, 0x01, 0x02, 0x03, 0x04];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        23,
        [1, 2, 3, 4]
      ]);
      expect(listener.lastTag, 23);
      expect(listener.lastByteCount, 4);
      decoder.setListener(slistener);
      input.reset();
      slistener.stack.clear();
      decoder.run();
      final List<dynamic> slist = slistener.stack.walk();
      expect(slist.length, 1);
      expect(slist[0], [1, 2, 3, 4]);
    });

    test('Tag (24) multiple', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xd8, 0x18, 0x45, 0x64, 0x49, 0x45, 0x54, 0x46];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        24,
        [100, 73, 69, 84, 70]
      ]);
      expect(listener.lastByteCount, 5);
      expect(listener.lastTag, 24);
    });

    test('Tag (32) URI', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xd8,
        0x20,
        0x76,
        0x68,
        0x74,
        0x74,
        0x70,
        0x3a,
        0x2f,
        0x2f,
        0x77,
        0x77,
        0x77,
        0x2e,
        0x65,
        0x78,
        0x61,
        0x6d,
        0x70,
        0x6c,
        0x65,
        0x2e,
        0x63,
        0x6f,
        0x6d
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [32, "http://www.example.com"]);
      expect(listener.lastTag, 32);
    });

    test('Empty single quotes', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x40];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [[]]);
    });

    test('4 bytes', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x44, 0x01, 0x02, 0x03, 0x04];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        [01, 02, 03, 04]
      ]);
      expect(listener.lastByteCount, 4);
    });

    test('Empty double quotes', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x60];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [""]);
    });

    test('a', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x61, 0x61];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["a"]);
    });

    test('IETF', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x64, 0x49, 0x45, 0x54, 0x46];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["IETF"]);
    });

    test('Quoted backslash', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x62, 0x22, 0x5c];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["\"\\"]);
    });

    test('Unicode ü', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x62, 0xc3, 0xbc];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ['ü']);
    });

    test('Unicode 水', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x63, 0xe6, 0xb0, 0xb4];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ['水']);
    });

    test('Unicode 𐅑', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x64, 0xf0, 0x90, 0x85, 0x91];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ['𐅑']);
    });

    test('Array empty', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x80];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastSize, 0);
    });

    test('Array 1,2,3', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x83, 0x01, 0x02, 0x03];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3]);
      expect(listener.lastSize, 3);
    });

    test('Array 1,2,3...25', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x98,
        0x19,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
      ]);
      expect(listener.lastSize, 25);
    });

    test('Nested array', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x83, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4, 5]);
      expect(listener.lastSize, 2);
    });

    test('Empty Map', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xa0];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, []);
      expect(listener.lastSize, 0);
    });

    test('{1: 2, 3: 4}', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xa2, 0x01, 0x02, 0x03, 0x04];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4]);
      expect(listener.lastSize, 2);
    });

    test('{"a": 1, "b": [2, 3]}', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xa2,
        0x61,
        0x61,
        0x01,
        0x61,
        0x62,
        0x82,
        0x02,
        0x03
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["a", 1, "b", 2, 3]);
      expect(listener.lastSize, 2);
    });

    test('{"a", {"b": "c"}', () {
      output.clear();
      listener.clear();
      final List<int> values = [0xa2, 0x61, 0x61, 0xa1, 0x61, 0x62, 0x61, 0x63];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["a", "b", "c"]);
      expect(listener.lastSize, 1);
    });

    test('{"a": "A", "b": "B", "c": "C", "d": "D", "e": "E"}', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xa5,
        0x61,
        0x61,
        0x61,
        0x41,
        0x61,
        0x62,
        0x61,
        0x42,
        0x61,
        0x63,
        0x61,
        0x43,
        0x61,
        0x64,
        0x61,
        0x44,
        0x61,
        0x65,
        0x61,
        0x45
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue,
          ["a", "A", "b", "B", "c", "C", "d", "D", "e", "E"]);
      expect(listener.lastSize, 5);
    });

    test("(_ h'0102', h'030405')", () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x5f,
        0x42,
        0x01,
        0x02,
        0x43,
        0x03,
        0x04,
        0x05,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        [1, 2],
        [3, 4, 5]
      ]);
      expect(listener.indefinateStart, isTrue);
    });

    test('(_ "strea", "ming")', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x7f,
        0x65,
        0x73,
        0x74,
        0x72,
        0x65,
        0x61,
        0x64,
        0x6d,
        0x69,
        0x6e,
        0x67,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["strea", "ming"]);
      expect(listener.indefinateStart, isTrue);
    });

    test('(_ "strea", "ming")', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x7f,
        0x65,
        0x73,
        0x74,
        0x72,
        0x65,
        0x61,
        0x64,
        0x6d,
        0x69,
        0x6e,
        0x67,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["strea", "ming"]);
      expect(listener.indefinateStart, isTrue);
    });

    test('[_ ]', () {
      output.clear();
      listener.clear();
      final List<int> values = [0x9f, 0xff];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, []);
      expect(listener.indefinateStart, isTrue);
    });

    test('[_ 1, [2, 3], [_4, 5]]', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x9f,
        0x01,
        0x82,
        0x02,
        0x03,
        0x9f,
        0x04,
        0x05,
        0xff,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4, 5]);
      expect(listener.indefinateStart, isTrue);
    });

    test('[_ 1, [2, 3], [4, 5]]', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x9f,
        0x01,
        0x82,
        0x02,
        0x03,
        0x82,
        0x04,
        0x05,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4, 5]);
      expect(listener.indefinateStart, isTrue);
    });

    test('[1, [2, 3], [_ 4, 5]]', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x83,
        0x01,
        0x82,
        0x02,
        0x03,
        0x9f,
        0x04,
        0x05,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4, 5]);
      expect(listener.indefinateStart, isTrue);
    });

    test('[1, [_ 2, 3], [4, 5]]', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x83,
        0x01,
        0x9f,
        0x02,
        0x03,
        0xff,
        0x82,
        0x04,
        0x05
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [1, 2, 3, 4, 5]);
      expect(listener.indefinateStart, isTrue);
    });

    test('[_ 1, 2, 3 .. 25]', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x9f,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0a,
        0x0b,
        0x0c,
        0x0d,
        0x0e,
        0x0f,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25
      ]);
      expect(listener.indefinateStart, isTrue);
    });

    test('{_ "a":1, "b": [_ 2,3]}', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xbf,
        0x61,
        0x61,
        0x01,
        0x61,
        0x62,
        0x9f,
        0x02,
        0x03,
        0xff,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["a", 1, "b", 2, 3]);
      expect(listener.indefinateStart, isTrue);
    });

    test('["a", {_ "b": "c"}] }', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0x82,
        0x61,
        0x61,
        0xbf,
        0x61,
        0x62,
        0x61,
        0x63,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["a", "b", "c"]);
      expect(listener.indefinateStart, isTrue);
    });

    test('{_ "Fun": true, "Amt": -2}', () {
      output.clear();
      listener.clear();
      final List<int> values = [
        0xbf,
        0x63,
        0x46,
        0x75,
        0x6e,
        0xf5,
        0x63,
        0x41,
        0x6d,
        0x74,
        0x21,
        0xff
      ];
      final typed.Uint8Buffer buffer = new typed.Uint8Buffer();
      buffer.addAll(values);
      output.putBytes(buffer);
      final cbor.Input input = new cbor.Input(output.getData(), output.size());
      final cbor.Decoder decoder =
      new cbor.Decoder.withListener(input, listener);
      decoder.run();
      expect(listener.lastValue, ["Fun", true, "Amt", -2]);
      expect(listener.indefinateStart, isTrue);
    });
  });
}