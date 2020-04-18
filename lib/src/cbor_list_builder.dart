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
  /// Construction, supply your own output.
  ListBuilder(Output out) : super(out) {
    init();
    _builderHook = _hook;
  }

  /// Get a list builder with its own output
  static ListBuilder builder() {
    Output out = OutputStandard();
    return ListBuilder(out);
  }

  // The list items
  final List<typed.Uint8Buffer> _items = <typed.Uint8Buffer>[];

  /// The built list
  typed.Uint8Buffer _built = typed.Uint8Buffer();

  // Get the built list
  typed.Uint8Buffer getData() {
    if (_built.isEmpty) {
      writeArrayImpl(_items);
      _built = _out._buffer;
    }
    return _built;
  }

  /// Clear
  @override
  void clear() {
    _out.clear();
    _items.clear();
  }

  // The builder hook. List builder
  // doesn't care about the map key parameter.
  void _hook(bool validAsMapKey, dynamic keyValue) {
    _items.add(_out.getData());
    _out.clear();
  }
}
