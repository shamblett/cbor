/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 20/01/2026
 * Copyright :  S.Hamblett
 */

// Determine the runtime environment for testing
const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');
const bool kIsWasm = bool.fromEnvironment('dart.tool.dart2wasm');
const bool kIsVm = bool.fromEnvironment('dart.library.dart:io');

// If we are running wasm or vm do not skip tests
bool skipJSTest = true;

void setEnvironment() {
  if (kIsWasm || kIsVm) {
    skipJSTest = false;
  }
}
