/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

part of cbor;

/// A Dart item linked list entry for use by the stack
class ItemEntry<DartItem> extends LinkedListEntry {
  DartItem value;

  ItemEntry(this.value);

  String toString() => "${super.toString()} : value.toString()";
}


/// The decoded Dart item stack class
class ItemStack {

  LinkedList _stack = new LinkedList();

  /// Get the item stack
  get stack => _stack;

}