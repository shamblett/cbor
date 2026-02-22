import 'package:cbor/cbor.dart';
import 'package:test/test.dart';

void main() {
  group('CborJsonEncoder startChunkedConversion', () {
    test('works as stream transformer', () async {
      final encoder = const CborJsonEncoder();

      final cborList = CborList([
        CborSmallInt(1),
        CborString('hello'),
        CborMap({CborString('a'): CborSmallInt(2)}),
      ]);

      final stream = Stream<CborValue>.fromIterable([cborList]);
      final jsonStrings = await stream.transform(encoder).toList();

      expect(jsonStrings.join(), equals('[1,"hello",{"a":2}]'));
    });
  });

  group('CborSimpleEncoder startChunkedConversion', () {
    test('works as stream transformer', () async {
      final encoder = const CborSimpleEncoder();
      final stream = Stream<Object?>.fromIterable([1, 'hello']);
      final encodedBytes = await stream.transform(encoder).toList();

      final decoder = const CborSimpleDecoder();

      final flatBytes = encodedBytes.expand((x) => x).toList();

      final decodedObjects =
          await Stream<List<int>>.fromIterable([
            flatBytes,
          ]).transform(decoder).toList();
      expect(decodedObjects, equals([1, 'hello']));
    });
  });

  group('CborSimpleDecoder startChunkedConversion', () {
    test('works as stream transformer', () async {
      final decoder = const CborSimpleDecoder();
      final encoder = const CborSimpleEncoder();
      final bytes1 = encoder.convert([1, 'hello']);
      final bytes2 = encoder.convert({'a': 2});

      final stream = Stream<List<int>>.fromIterable([
        bytes1.sublist(0, 3),
        bytes1.sublist(3),
        bytes2,
      ]);
      final decodedObjects = await stream.transform(decoder).toList();
      expect(
        decodedObjects,
        equals([
          [1, 'hello'],
          {'a': 2},
        ]),
      );
    });
  });
}
