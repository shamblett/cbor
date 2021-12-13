/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

/// The information encoded by additional info and the following bytes.
abstract class Info {
  const factory Info.int(int Info) = _InfoInt;

  factory Info.bigInt(BigInt Info) = _InfoBigInt;

  Info operator ~();

  bool get isIndefiniteLength;

  int toInt();
  BigInt toBigInt();
  int get bitLength;

  static const Info indefiniteLength = _InfoIndefiniteLength();
}

class _InfoIndefiniteLength implements Info {
  const _InfoIndefiniteLength();

  @override
  _InfoIndefiniteLength operator ~() => this;

  @override
  final bool isIndefiniteLength = true;

  @override
  final int bitLength = 0;
  @override
  int toInt() => 0;
  @override
  BigInt toBigInt() => BigInt.zero;
}

class _InfoInt implements Info {
  const _InfoInt(this.value);

  final int value;

  @override
  _InfoInt operator ~() => _InfoInt(~value);

  @override
  final bool isIndefiniteLength = false;

  @override
  int get bitLength => value.bitLength;
  @override
  int toInt() => value;
  @override
  BigInt toBigInt() => BigInt.from(value);
}

class _InfoBigInt implements Info {
  _InfoBigInt(this.value);

  final BigInt value;

  @override
  _InfoBigInt operator ~() => _InfoBigInt(~value);

  @override
  final bool isIndefiniteLength = false;

  @override
  int get bitLength => value.bitLength;
  @override
  int toInt() => value.toInt();
  @override
  BigInt toBigInt() => value;
}
