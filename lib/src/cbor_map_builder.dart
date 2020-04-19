/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/04/2020
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Map builder class.
///
/// Allows the building of maps that contain complex values.
///
/// Maps are built in a key, value order, a key can be a string or integer type,
/// values can be any encodable CBOR item including tag based values
/// lists, maps, and the output of any other built sequences.
/// This ordering is enforced, it is up to the user to build the map correctly.
///
/// The output of the build process is the CBOR encoded byte list.
/// This can be simply appended to any existing encoding sequence.
class MapBuilder extends Encoder {
  /// Construction, supply your own output.
  MapBuilder(Output out) : super(out) {
    init();
    _builderHook = _hook;
  }

  /// Get a map builder with its own output
  static MapBuilder builder() {
    Output out = OutputStandard();
    return MapBuilder(out);
  }

  // The list of key items
  final List<dynamic> _keyItems = <dynamic>[];

  // The list of value items
  final List<typed.Uint8Buffer> _valueItems = <typed.Uint8Buffer>[];

  // The built map
  final Map<dynamic, typed.Uint8Buffer> _builtMap =
      <dynamic, typed.Uint8Buffer>{};

  // Key or value expected
  bool _expectingKey = true;

  // Build and return the map
  typed.Uint8Buffer getData() {
    // Check the length of the item lists
    if (_keyItems.length != _valueItems.length) {
      throw CborException(
          'Map Builder - unmatched key/value pairs, cannot build map,'
          'there are ${_keyItems.length} keys and ${_valueItems.length} values');
    }
    for (var i = 0; i < _keyItems.length; i++) {
      _builtMap[_keyItems[i]] = _valueItems[i];
    }
    _writeMapImpl(_builtMap);
    return _out._buffer;
  }

  /// Clear
  @override
  void clear() {
    _out.clear();
    _keyItems.clear();
    _valueItems.clear();
  }

  // The builder hook.
  void _hook(bool validAsMapKey, dynamic keyValue) {
    // If we are expecting a key check we have a valid one.
    if (_expectingKey) {
      if (!validAsMapKey) {
        throw CborException(
            'Map Builder - key expected but type is not valid for a map key');
      }
      _keyItems.add(keyValue);
    } else {
      // Value
      _valueItems.add(_out.getData());
    }
    _expectingKey = !_expectingKey;
    _out.clear();
  }
}
