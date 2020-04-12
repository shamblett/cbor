/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/04/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

/// List builder class.
///
/// Allows the building of lists that contain complex values such as
/// bignums, tags etc.
/// The output of the build process is the CBOR encoded byte list.
/// This can be simply appended to any existing encoding sequence.
class ListBuilder extends Encoder {
  /// Construction
  ListBuilder(Output out) : super(out) {
    _builderHook = _hook;
  }

  // The list items
  final List<typed.Uint8Buffer> _items = <typed.Uint8Buffer>[];

  // The raw list
  final typed.Uint8Buffer _rawList = typed.Uint8Buffer();

  // Get the built list
  typed.Uint8Buffer getData() {
    // Build the items into a CBOR list and return it.
    return _rawList;
  }

  // The builder hook. List builder
  // doesn't care about the map key parameter.
  void _hook(bool validAsMapKey) {
    _items.add(_out.getData());
    _out.clear();
  }
}
