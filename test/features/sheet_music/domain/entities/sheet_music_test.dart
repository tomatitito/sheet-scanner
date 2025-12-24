import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

void main() {
  group('SheetMusic Entity', () {
    final baseDate = DateTime(2025, 12, 24, 10, 30, 0);

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Moonlight Sonata',
      composer: 'Ludwig van Beethoven',
      notes: 'A beautiful classical piece',
      imageUrls: const ['image1.png', 'image2.png'],
      tags: const ['classical', 'piano', 'beethoven'],
      createdAt: baseDate,
      updatedAt: baseDate,
    );

    test('SheetMusic can be created with all required fields', () {
      expect(tSheetMusic.id, 1);
      expect(tSheetMusic.title, 'Moonlight Sonata');
      expect(tSheetMusic.composer, 'Ludwig van Beethoven');
    });

    test('SheetMusic stores all optional fields', () {
      expect(tSheetMusic.notes, 'A beautiful classical piece');
      expect(tSheetMusic.imageUrls, ['image1.png', 'image2.png']);
      expect(tSheetMusic.tags, ['classical', 'piano', 'beethoven']);
    });

    test('SheetMusic has timestamps', () {
      expect(tSheetMusic.createdAt, baseDate);
      expect(tSheetMusic.updatedAt, baseDate);
    });

    test('SheetMusic.copyWith creates new instance with changed fields', () {
      final updated = tSheetMusic.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.composer, tSheetMusic.composer);
      expect(updated.id, tSheetMusic.id);
    });

    test('SheetMusic.copyWith preserves unchanged fields', () {
      final updated = tSheetMusic.copyWith(title: 'New Title');
      expect(updated.composer, 'Ludwig van Beethoven');
      expect(updated.notes, 'A beautiful classical piece');
      expect(updated.imageUrls, tSheetMusic.imageUrls);
      expect(updated.tags, tSheetMusic.tags);
    });

    test('SheetMusic.copyWith updates multiple fields', () {
      final updated = tSheetMusic.copyWith(
        title: 'Tempest Sonata',
        composer: 'Ludwig van Beethoven',
        notes: 'A dramatic piece',
      );
      expect(updated.title, 'Tempest Sonata');
      expect(updated.composer, 'Ludwig van Beethoven');
      expect(updated.notes, 'A dramatic piece');
    });

    test('SheetMusic.copyWith handles date changes', () {
      final newDate = DateTime(2025, 12, 25);
      final updated = tSheetMusic.copyWith(updatedAt: newDate);
      expect(updated.updatedAt, newDate);
      expect(updated.createdAt, baseDate);
    });

    test('SheetMusic.copyWith handles empty lists', () {
      final updated = tSheetMusic.copyWith(
        tags: const [],
        imageUrls: const [],
      );
      expect(updated.tags, isEmpty);
      expect(updated.imageUrls, isEmpty);
    });

    test('SheetMusic with default empty lists', () {
      final sheet = SheetMusic(
        id: 2,
        title: 'Test',
        composer: 'Test Composer',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      expect(sheet.imageUrls, isEmpty);
      expect(sheet.tags, isEmpty);
      expect(sheet.notes, isNull);
    });

    test('SheetMusic equality based on field values', () {
      final sheet1 = SheetMusic(
        id: 1,
        title: 'Test',
        composer: 'Composer',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      final sheet2 = SheetMusic(
        id: 1,
        title: 'Test',
        composer: 'Composer',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      expect(sheet1, sheet2);
    });

    test('SheetMusic inequality when IDs differ', () {
      final sheet1 = SheetMusic(
        id: 1,
        title: 'Test',
        composer: 'Composer',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      final sheet2 = SheetMusic(
        id: 2,
        title: 'Test',
        composer: 'Composer',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      expect(sheet1, isNot(sheet2));
    });

    test('SheetMusic handles special characters in title', () {
      final sheet = SheetMusic(
        id: 1,
        title: 'Symphony No. 9 "Ode to Joy" (特別版)',
        composer: 'Ludwig van Beethoven',
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      expect(sheet.title, contains('特別版'));
      expect(sheet.title, contains('Ode to Joy'));
    });

    test('SheetMusic handles many tags', () {
      final manyTags = List.generate(100, (i) => 'tag_$i');
      final sheet = tSheetMusic.copyWith(tags: manyTags);
      expect(sheet.tags.length, 100);
      expect(sheet.tags.contains('tag_0'), true);
      expect(sheet.tags.contains('tag_99'), true);
    });

    test('SheetMusic handles many images', () {
      final manyImages = List.generate(50, (i) => 'image_$i.png');
      final sheet = tSheetMusic.copyWith(imageUrls: manyImages);
      expect(sheet.imageUrls.length, 50);
      expect(sheet.imageUrls.first, 'image_0.png');
      expect(sheet.imageUrls.last, 'image_49.png');
    });

    test('SheetMusic timestamps are independent', () {
      final createdDate = DateTime(2025, 12, 24);
      final updatedDate = DateTime(2025, 12, 25);
      final sheet = SheetMusic(
        id: 1,
        title: 'Test',
        composer: 'Composer',
        createdAt: createdDate,
        updatedAt: updatedDate,
      );
      expect(sheet.createdAt.isBefore(sheet.updatedAt), true);
    });

    test('SheetMusic copyWith with null notes', () {
      final sheet = tSheetMusic.copyWith(notes: null);
      expect(sheet.notes, isNull);
    });

    test('SheetMusic nullable fields can remain null after copyWith', () {
      final sheet = SheetMusic(
        id: 1,
        title: 'Test',
        composer: 'Composer',
        notes: null,
        createdAt: baseDate,
        updatedAt: baseDate,
      );
      final updated = sheet.copyWith(notes: null);
      expect(updated.notes, isNull);
    });
  });
}
