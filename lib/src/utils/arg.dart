/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/01/2022
 * Copyright :  S.Hamblett
 */

import '../constants.dart';

/// The information encoded by additional Arg and the following bytes.
abstract class Arg {
  static const Arg indefiniteLength = _ArgIndefiniteLength();

  bool get isIndefiniteLength;

  bool get isValidInt;

  const factory Arg.int(int arg) = _ArgInt;

  factory Arg.bigInt(BigInt arg) = _ArgBigInt;

  Arg operator ~();

  int toInt();
  BigInt toBigInt();
}

class _ArgIndefiniteLength implements Arg {
  @override
  final bool isIndefiniteLength = true;

  @override
  final bool isValidInt = false;

  const _ArgIndefiniteLength();

  @override
  _ArgIndefiniteLength operator ~() => this;

  @override
  int toInt() => 0;
  @override
  BigInt toBigInt() => BigInt.zero;
}

class _ArgInt implements Arg {
  final int value;

  @override
  final bool isIndefiniteLength = false;

  @override
  final bool isValidInt = true;

  const _ArgInt(this.value);

  @override
  _ArgInt operator ~() => _ArgInt((~BigInt.from(value)).toSigned(CborConstants.bigIntSlice).toInt());

  @override
  int toInt() => value;
  @override
  BigInt toBigInt() => BigInt.from(value);
}

class _ArgBigInt implements Arg {
  final BigInt value;

  @override
  final bool isIndefiniteLength = false;

  @override
  final bool isValidInt = false;

  _ArgBigInt(this.value);

  @override
  _ArgBigInt operator ~() => _ArgBigInt(~value);

  @override
  int toInt() => value.toInt();
  @override
  BigInt toBigInt() => value;
}
