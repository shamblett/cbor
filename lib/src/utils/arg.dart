/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import 'utils.dart';

/// The information encoded by additional Arg and the following bytes.
abstract class Arg {
  const factory Arg.int(int arg) = _ArgInt;

  factory Arg.bigInt(BigInt arg) = _ArgBigInt;

  Arg operator ~();

  bool get isIndefiniteLength;

  int toInt();
  BigInt toBigInt();
  bool get isValidInt;

  static const Arg indefiniteLength = _ArgIndefiniteLength();
}

class _ArgIndefiniteLength implements Arg {
  const _ArgIndefiniteLength();

  @override
  _ArgIndefiniteLength operator ~() => this;

  @override
  final bool isIndefiniteLength = true;

  @override
  final bool isValidInt = false;
  @override
  int toInt() => 0;
  @override
  BigInt toBigInt() => BigInt.zero;
}

class _ArgInt implements Arg {
  const _ArgInt(this.value);

  final int value;

  @override
  _ArgInt operator ~() => _ArgInt(kIsWeb ? -value - 1 : ~value);

  @override
  final bool isIndefiniteLength = false;

  @override
  final bool isValidInt = true;
  @override
  int toInt() => value;
  @override
  BigInt toBigInt() => BigInt.from(value);
}

class _ArgBigInt implements Arg {
  _ArgBigInt(this.value);

  final BigInt value;

  @override
  _ArgBigInt operator ~() => _ArgBigInt(~value);

  @override
  final bool isIndefiniteLength = false;

  @override
  final bool isValidInt = false;
  @override
  int toInt() => value.toInt();
  @override
  BigInt toBigInt() => value;
}
