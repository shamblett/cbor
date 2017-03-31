/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// Decoder states
enum DecoderState {
  type,
  pint,
  nint,
  bytesSize,
  bytesData,
  stringSize,
  stringData,
  array,
  map,
  tag,
  special,
  error
}

/// Length constants
const int oneByte = 1;
const int twoByte = 2;
const int fourByte = 4;
const int eightByte = 8;

/// The decoder class implements the CBOR decoder functionality as defined in
/// RFC7049. Output from the decoding process is through the Listener class interface.
/// Different listener classes can be supplied for different purposes, such as test,
/// debug as well as the standard stack listener.
class Decoder {
  Listener _listener;
  Input _input;
  DecoderState _state;
  int _currentLength;

  Decoder(Input input) {
    _input = input;
    _state = DecoderState.type;
  }

  Decoder.withListener(Input input, Listener listener) {
    _input = input;
    _state = DecoderState.type;
    _listener = listener;
  }

  /// Decoder entry point.
  void run() {
    int temp;
    final bool run = true;
    while (run) {
      if (_state == DecoderState.type) {
        if (_input.hasBytes(1)) {
          final int type = _input.getByte();
          final int majorType = type >> majorTypeShift;
          final int minorType = type & minorTypeMask;

          switch (majorType) {
            case majorTypePint: // positive integer
              if (minorType < ai24) {
                _listener.onInteger(minorType);
              } else if (minorType == ai24) {
                // 1 byte
                _currentLength = oneByte;
                _state = DecoderState.pint;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.pint;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.pint;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.pint;
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid positive integer type");
              }
              break;
            case majorTypeNint: // negative integer
              if (minorType < ai24) {
                _listener.onInteger(-1 - minorType);
              } else if (minorType == ai24) {
                // 1 byte
                _currentLength = oneByte;
                _state = DecoderState.nint;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.nint;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.nint;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.nint;
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid negative integer type");
              }
              break;
            case majorTypeBytes: // bytes
              if (minorType < ai24) {
                _state = DecoderState.bytesData;
                _currentLength = minorType;
              } else if (minorType == ai24) {
                _state = DecoderState.bytesSize;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.bytesSize;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.bytesSize;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.bytesSize;
              } else if (minorType == aiBreak) {
                _state = DecoderState.type;
                _listener.onIndefinite("bytes");
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid bytes type");
              }
              break;
            case majorTypeString: // string
              if (minorType < ai24) {
                _state = DecoderState.stringData;
                _currentLength = minorType;
              } else if (minorType == ai24) {
                _state = DecoderState.stringSize;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.stringSize;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.stringSize;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.stringSize;
              } else if (minorType == aiBreak) {
                _state = DecoderState.type;
                _listener.onIndefinite("string");
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid string type");
              }
              break;
            case majorTypeArray: // array
              if (minorType < ai24) {
                _listener.onArray(minorType);
              } else if (minorType == ai24) {
                _state = DecoderState.array;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.array;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.array;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.array;
              } else if (minorType == aiBreak) {
                _state = DecoderState.type;
                _listener.onIndefinite("array");
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid array type");
              }
              break;
            case majorTypeMap: // map
              if (minorType < ai24) {
                _listener.onMap(minorType);
              } else if (minorType == ai24) {
                _state = DecoderState.map;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.map;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.map;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.map;
              } else if (minorType == aiBreak) {
                _state = DecoderState.type;
                _listener.onIndefinite("map");
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid map type");
              }
              break;
            case majorTypeTag: // tag
              if (minorType < ai24) {
                _listener.onTag(minorType);
              } else if (minorType == ai24) {
                _state = DecoderState.tag;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.tag;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.tag;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.tag;
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid tag type");
              }
              break;
            case majorTypeSpecial: // special
              if (minorType < ai20) {
                _listener.onSpecial(minorType);
              } else if (minorType == ai20) {
                _listener.onBool(false);
              } else if (minorType == ai21) {
                _listener.onBool(true);
              } else if (minorType == ai22) {
                _listener.onNull();
              } else if (minorType == ai23) {
                _listener.onUndefined();
              } else if (minorType == ai24) {
                _state = DecoderState.special;
                _currentLength = oneByte;
              } else if (minorType == ai25) {
                // 2 byte
                _currentLength = twoByte;
                _state = DecoderState.special;
              } else if (minorType == ai26) {
                // 4 byte
                _currentLength = fourByte;
                _state = DecoderState.special;
              } else if (minorType == ai27) {
                // 8 byte
                _currentLength = eightByte;
                _state = DecoderState.special;
              } else if (minorType == aiBreak) {
                _state = DecoderState.type;
                _listener.onIndefinite("stop");
              } else {
                _state = DecoderState.error;
                _listener.onError("Decoder::invalid special type");
              }
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.pint) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(_input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              _listener.onInteger(_input.getShort());
              _state = DecoderState.type;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= two32) {
                _listener.onInteger(temp);
              } else {
                _listener.onExtraInteger(temp, 1);
              }
              _state = DecoderState.type;
              break;
            case 8:
              _listener.onExtraInteger(_input.getLong(), 1);
              _state = DecoderState.type;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.nint) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(-1 - _input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              _listener.onInteger(-1 - _input.getShort());
              _state = DecoderState.type;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= two32) {
                _listener.onInteger(-1 - temp);
              } else if (temp == two32 + 1) {
                _listener.onInteger(-two32 - 1);
              } else {
                _listener.onExtraInteger((-1 - temp), -1);
              }
              _state = DecoderState.type;
              break;
            case 8:
              _listener.onExtraInteger((-1 - _input.getLong()), -1);
              _state = DecoderState.type;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.bytesSize) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.bytesData;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.bytesData;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.bytesData;
              break;
            case 8:
              _state = DecoderState.error;
              _listener.onError("Decoder::extra long bytes");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.bytesData) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          data = _input.getBytes(_currentLength);
          _state = DecoderState.type;
          _listener.onBytes(data, _currentLength);
        } else
          break;
      } else if (_state == DecoderState.stringSize) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.stringData;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.stringData;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.stringData;
              break;
            case 8:
              _state = DecoderState.error;
              _listener.onError("Decoder::extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stringData) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          data = _input.getBytes(_currentLength);
          final convertor.Utf8Decoder decoder = new convertor.Utf8Decoder();
          final String tmp = decoder.convert(data);
          _listener.onString(tmp);
          _state = DecoderState.type;
        } else
          break;
      } else if (_state == DecoderState.array) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onArray(_input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              _listener.onArray(_input.getShort());
              _state = DecoderState.type;
              break;
            case 4:
              _listener.onArray(_input.getInt());
              _state = DecoderState.type;
              break;
            case 8:
              _state = DecoderState.error;
              _listener.onError("Decoder::extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.map) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onMap(_input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              _listener.onMap(_currentLength = _input.getShort());
              _state = DecoderState.type;
              break;
            case 4:
              _listener.onMap(_input.getInt());
              _state = DecoderState.type;
              break;
            case 8:
              _state = DecoderState.error;
              _listener.onError("Decoder::extra long map");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.tag) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onTag(_input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              _listener.onTag(_input.getShort());
              _state = DecoderState.type;
              break;
            case 4:
              _listener.onTag(_input.getInt());
              _state = DecoderState.type;
              break;
            case 8:
              _listener.onExtraTag(_input.getLong());
              _state = DecoderState.type;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.special) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onSpecial(_input.getByte());
              _state = DecoderState.type;
              break;
            case 2:
              final int val = _input.getShort();
              final double fval = _input.getHalfFloat(val);
              _listener.onSpecialFloat(fval);
              _state = DecoderState.type;
              break;
            case 4:
              final typed.Uint8Buffer buff = _input.getBytes(_currentLength);
              final double fval = _input.getSingleFloat(buff);
              _listener.onSpecialFloat(fval);
              _state = DecoderState.type;
              break;
            case 8:
              final typed.Uint8Buffer buff = _input.getBytes(_currentLength);
              final double fval = _input.getDoubleFloat(buff);
              _listener.onSpecialFloat(fval);
              _state = DecoderState.type;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.error) {
        _listener.onError("Decoder::general error");
        break;
      } else {
        _listener.onError("Decoder::unknown state");
      }
    }
  }

  /// Set a listener.
  void setListener(Listener listenerInstance) {
    _listener = listenerInstance;
  }
}
