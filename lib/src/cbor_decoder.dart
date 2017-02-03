/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

enum DecoderState {
  STATE_TYPE,
  STATE_PINT,
  STATE_NINT,
  STATE_BYTES_SIZE,
  STATE_BYTES_DATA,
  STATE_STRING_SIZE,
  STATE_STRING_DATA,
  STATE_ARRAY,
  STATE_MAP,
  STATE_TAG,
  STATE_SPECIAL,
  STATE_ERROR
}

class Decoder {
  Listener _listener;
  Input _input;
  DecoderState _state;
  int _currentLength;

  Decoder(Input input) {
    _input = input;
    _state = DecoderState.STATE_TYPE;
  }

  Decoder.withListener(Input input, Listener listener) {
    _input = input;
    _state = DecoderState.STATE_TYPE;
    _listener = listener;
  }

  void run() {
    int temp;
    while (true) {
      if (_state == DecoderState.STATE_TYPE) {
        if (_input.hasBytes(1)) {
          int type = _input.getByte();
          int majorType = type >> 5;
          int minorType = type & 31;

          switch (majorType) {
            case 0: // positive integer
              if (minorType < 24) {
                _listener.onInteger(minorType);
              } else if (minorType == 24) {
                // 1 byte
                _currentLength = 1;
                _state = DecoderState.STATE_PINT;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_PINT;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_PINT;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_PINT;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid integer type");
              }
              break;
            case 1: // negative integer
              if (minorType < 24) {
                _listener.onInteger(-1 - minorType);
              } else if (minorType == 24) {
                // 1 byte
                _currentLength = 1;
                _state = DecoderState.STATE_NINT;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_NINT;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_NINT;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_NINT;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid integer type");
              }
              break;
            case 2: // bytes
              if (minorType < 24) {
                _state = DecoderState.STATE_BYTES_DATA;
                _currentLength = minorType;
              } else if (minorType == 24) {
                _state = DecoderState.STATE_BYTES_SIZE;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_BYTES_SIZE;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_BYTES_SIZE;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_BYTES_SIZE;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid bytes type");
              }
              break;
            case 3: // string
              if (minorType < 24) {
                _state = DecoderState.STATE_STRING_DATA;
                _currentLength = minorType;
              } else if (minorType == 24) {
                _state = DecoderState.STATE_STRING_SIZE;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_STRING_SIZE;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_STRING_SIZE;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_STRING_SIZE;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid string type");
              }
              break;
            case 4: // array
              if (minorType < 24) {
                _listener.onArray(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.STATE_ARRAY;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_ARRAY;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_ARRAY;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_ARRAY;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid array type");
              }
              break;
            case 5: // map
              if (minorType < 24) {
                _listener.onMap(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.STATE_MAP;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_MAP;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_MAP;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_MAP;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid array type");
              }
              break;
            case 6: // tag
              if (minorType < 24) {
                _listener.onTag(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.STATE_TAG;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_TAG;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_TAG;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_TAG;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid tag type");
              }
              break;
            case 7: // special
              if (minorType < 20) {
                _listener.onSpecial(minorType);
              } else if (minorType == 20) {
                _listener.onBool(false);
              } else if (minorType == 21) {
                _listener.onBool(true);
              } else if (minorType == 22) {
                _listener.onNull();
              } else if (minorType == 23) {
                _listener.onUndefined();
              } else if (minorType == 24) {
                _state = DecoderState.STATE_SPECIAL;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.STATE_SPECIAL;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.STATE_SPECIAL;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.STATE_SPECIAL;
              } else {
                _state = DecoderState.STATE_ERROR;
                _listener.onError("invalid special type");
              }
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_PINT) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onInteger(_input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= 2 ^ 31) {
                _listener.onInteger(temp);
              } else {
                _listener.onExtraInteger(temp, 1);
              }
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _listener.onExtraInteger(_input.getLong(), 1);
              _state = DecoderState.STATE_TYPE;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_NINT) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(-_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onInteger(-_input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= 2 ^ 31) {
                _listener.onInteger(-temp);
              } else if (temp == 2 ^ 31) {
                _listener.onInteger(-2 ^ 31);
              } else {
                _listener.onExtraInteger(temp, -1);
              }
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _listener.onExtraInteger(_input.getLong(), -1);
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_BYTES_SIZE) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.STATE_BYTES_DATA;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.STATE_BYTES_DATA;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.STATE_BYTES_DATA;
              break;
            case 8:
              _state = DecoderState.STATE_ERROR;
              _listener.onError("extra long bytes");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_BYTES_DATA) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          _input.getBytes(data, _currentLength);
          _state = DecoderState.STATE_TYPE;
          _listener.onBytes(data, _currentLength);
        } else
          break;
      } else if (_state == DecoderState.STATE_STRING_SIZE) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.STATE_STRING_DATA;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.STATE_STRING_DATA;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.STATE_STRING_DATA;
              break;
            case 8:
              _state = DecoderState.STATE_ERROR;
              _listener.onError("extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_STRING_DATA) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          _input.getBytes(data, _currentLength);
          _state = DecoderState.STATE_TYPE;
          _listener.onString(data.toString());
        } else
          break;
      } else if (_state == DecoderState.STATE_ARRAY) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onArray(_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onArray(_currentLength = _input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              _listener.onArray(_input.getInt());
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _state = DecoderState.STATE_ERROR;
              _listener.onError("extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_MAP) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onMap(_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onMap(_currentLength = _input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              _listener.onMap(_input.getInt());
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _state = DecoderState.STATE_ERROR;
              _listener.onError("extra long map");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_TAG) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onTag(_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onTag(_input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              _listener.onTag(_input.getInt());
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _listener.onExtraTag(_input.getLong());
              _state = DecoderState.STATE_TYPE;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_SPECIAL) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onSpecial(_input.getByte());
              _state = DecoderState.STATE_TYPE;
              break;
            case 2:
              _listener.onSpecial(_input.getShort());
              _state = DecoderState.STATE_TYPE;
              break;
            case 4:
              _listener.onSpecial(_input.getInt());
              _state = DecoderState.STATE_TYPE;
              break;
            case 8:
              _listener.onExtraSpecial(_input.getLong());
              _state = DecoderState.STATE_TYPE;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.STATE_ERROR) {
        break;
      } else {
        print("Decoder::run - UNKNOWN STATE");
      }
    }
  }

  void setListener(Listener listenerInstance) {
    _listener = listenerInstance;
  }
}
