/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

enum DecoderState {
  stateType,
  statePint,
  stateNint,
  stateBytesSize,
  stateBytesData,
  stateStringSize,
  stateStringData,
  stateArray,
  stateMap,
  stateTag,
  stateSpecial,
  stateError
}

class Decoder {
  Listener _listener;
  Input _input;
  DecoderState _state;
  int _currentLength;

  Decoder(Input input) {
    _input = input;
    _state = DecoderState.stateType;
  }

  Decoder.withListener(Input input, Listener listener) {
    _input = input;
    _state = DecoderState.stateType;
    _listener = listener;
  }

  void run() {
    int temp;
    final bool run = true;
    while (run) {
      if (_state == DecoderState.stateType) {
        if (_input.hasBytes(1)) {
          final int type = _input.getByte();
          final int majorType = type >> 5;
          final int minorType = type & 31;

          switch (majorType) {
            case 0: // positive integer
              if (minorType < 24) {
                _listener.onInteger(minorType);
              } else if (minorType == 24) {
                // 1 byte
                _currentLength = 1;
                _state = DecoderState.statePint;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.statePint;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.statePint;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.statePint;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid integer type");
              }
              break;
            case 1: // negative integer
              if (minorType < 24) {
                _listener.onInteger(-1 - minorType);
              } else if (minorType == 24) {
                // 1 byte
                _currentLength = 1;
                _state = DecoderState.stateNint;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateNint;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateNint;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateNint;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid integer type");
              }
              break;
            case 2: // bytes
              if (minorType < 24) {
                _state = DecoderState.stateBytesData;
                _currentLength = minorType;
              } else if (minorType == 24) {
                _state = DecoderState.stateBytesSize;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateBytesSize;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateBytesSize;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateBytesSize;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid bytes type");
              }
              break;
            case 3: // string
              if (minorType < 24) {
                _state = DecoderState.stateStringData;
                _currentLength = minorType;
              } else if (minorType == 24) {
                _state = DecoderState.stateStringSize;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateStringSize;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateStringSize;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateStringSize;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid string type");
              }
              break;
            case 4: // array
              if (minorType < 24) {
                _listener.onArray(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.stateArray;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateArray;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateArray;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateArray;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid array type");
              }
              break;
            case 5: // map
              if (minorType < 24) {
                _listener.onMap(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.stateMap;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateMap;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateMap;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateMap;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid array type");
              }
              break;
            case 6: // tag
              if (minorType < 24) {
                _listener.onTag(minorType);
              } else if (minorType == 24) {
                _state = DecoderState.stateTag;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateTag;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateTag;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateTag;
              } else {
                _state = DecoderState.stateError;
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
                _state = DecoderState.stateSpecial;
                _currentLength = 1;
              } else if (minorType == 25) {
                // 2 byte
                _currentLength = 2;
                _state = DecoderState.stateSpecial;
              } else if (minorType == 26) {
                // 4 byte
                _currentLength = 4;
                _state = DecoderState.stateSpecial;
              } else if (minorType == 27) {
                // 8 byte
                _currentLength = 8;
                _state = DecoderState.stateSpecial;
              } else {
                _state = DecoderState.stateError;
                _listener.onError("invalid special type");
              }
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.statePint) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(_input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onInteger(_input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= 2 ^ 31) {
                _listener.onInteger(temp);
              } else {
                _listener.onExtraInteger(temp, 1);
              }
              _state = DecoderState.stateType;
              break;
            case 8:
              _listener.onExtraInteger(_input.getLong(), 1);
              _state = DecoderState.stateType;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateNint) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onInteger(-1 - _input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onInteger(-1 - _input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              temp = _input.getInt();
              if (temp <= 2 ^ 31) {
                _listener.onInteger(-temp);
              } else if (temp >= 2 ^ 31) {
                _listener.onInteger(-2 ^ 31);
              } else {
                _listener.onExtraInteger((-1 - temp), -1);
              }
              _state = DecoderState.stateType;
              break;
            case 8:
              _listener.onExtraInteger((-1 - _input.getLong()), -1);
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateBytesSize) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.stateBytesData;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.stateBytesData;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.stateBytesData;
              break;
            case 8:
              _state = DecoderState.stateError;
              _listener.onError("extra long bytes");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateBytesData) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          data = _input.getBytes(_currentLength);
          _state = DecoderState.stateType;
          _listener.onBytes(data, _currentLength);
        } else
          break;
      } else if (_state == DecoderState.stateStringSize) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _currentLength = _input.getByte();
              _state = DecoderState.stateStringData;
              break;
            case 2:
              _currentLength = _input.getShort();
              _state = DecoderState.stateStringData;
              break;
            case 4:
              _currentLength = _input.getInt();
              _state = DecoderState.stateStringData;
              break;
            case 8:
              _state = DecoderState.stateError;
              _listener.onError("extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateStringData) {
        if (_input.hasBytes(_currentLength)) {
          typed.Uint8Buffer data;
          data = _input.getBytes(_currentLength);
          _state = DecoderState.stateType;
          _listener.onString(data);
        } else
          break;
      } else if (_state == DecoderState.stateArray) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onArray(_input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onArray(_currentLength = _input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              _listener.onArray(_input.getInt());
              _state = DecoderState.stateType;
              break;
            case 8:
              _state = DecoderState.stateError;
              _listener.onError("extra long array");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateMap) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onMap(_input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onMap(_currentLength = _input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              _listener.onMap(_input.getInt());
              _state = DecoderState.stateType;
              break;
            case 8:
              _state = DecoderState.stateError;
              _listener.onError("extra long map");
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateTag) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onTag(_input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onTag(_input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              _listener.onTag(_input.getInt());
              _state = DecoderState.stateType;
              break;
            case 8:
              _listener.onExtraTag(_input.getLong());
              _state = DecoderState.stateType;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateSpecial) {
        if (_input.hasBytes(_currentLength)) {
          switch (_currentLength) {
            case 1:
              _listener.onSpecial(_input.getByte());
              _state = DecoderState.stateType;
              break;
            case 2:
              _listener.onSpecial(_input.getShort());
              _state = DecoderState.stateType;
              break;
            case 4:
              _listener.onSpecial(_input.getInt());
              _state = DecoderState.stateType;
              break;
            case 8:
              _listener.onExtraSpecial(_input.getLong());
              _state = DecoderState.stateType;
              break;
          }
        } else
          break;
      } else if (_state == DecoderState.stateError) {
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
