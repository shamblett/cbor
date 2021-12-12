/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

/// Returns whether T is a subtype of U.
bool isSubtype<T, U>() => _Helper<T>() is _Helper<U>;

class _Helper<T> {
  const _Helper();
}
