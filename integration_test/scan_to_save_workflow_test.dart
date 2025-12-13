import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/router/app_router.dart';
import 'package:sheet_scanner/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Mock OCR Repository for testing that returns predictable results
class MockOCRRepository implements OCRRepository {
  @override
  Future<Either<Failure, OCRResult>> recognizeText(String imagePath) async {
    // Simulate OCR processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock OCR results
    return Right(
      OCRResult(
        text: 'Test Title\nTest Composer',
        confidence: 0.95,
      ),
    );
  }

  @override
  Future<Either<Failure, List<OCRResult>>> recognizeTextBatch(
    List<String> imagePaths,
  ) async {
    return Right(
      imagePaths
          .map((path) => OCRResult(
                text: 'Test Title\nTest Composer',
                confidence: 0.95,
              ))
          .toList(),
    );
  }

  @override
  Future<Either<Failure, bool>> isOCRAvailable() async {
    return Right(true);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scan-to-Save Workflow Integration Tests', () {
    late File testImage;
    late AppDatabase testDatabase;

    setUpAll(() async {
      // Create a test image file
      final tempDir = await getTemporaryDirectory();
      testImage = File(path.join(tempDir.path, 'test_sheet_music.jpg'));

      // Create a minimal test image (1x1 pixel)
      await testImage.writeAsBytes([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x00,
        0x10,
        0x4A,
        0x46,
        0x49,
        0x46,
        0x00,
        0x01,
        0x01,
        0x00,
        0x00,
        0x01,
        0x00,
        0x01,
        0x00,
        0x00,
        0xFF,
        0xDB,
        0x00,
        0x43,
        0x00,
        0x08,
        0x06,
        0x06,
        0x07,
        0x06,
        0x05,
        0x08,
        0x07,
        0x07,
        0x07,
        0x09,
        0x09,
        0x08,
        0x0A,
        0x0C,
        0x14,
        0x0D,
        0x0C,
        0x0B,
        0x0B,
        0x0C,
        0x19,
        0x12,
        0x13,
        0x0F,
        0x14,
        0x1D,
        0x1A,
        0x1F,
        0x1E,
        0x1D,
        0x1A,
        0x1C,
        0x1C,
        0x20,
        0x24,
        0x2E,
        0x27,
        0x20,
        0x22,
        0x2C,
        0x23,
        0x1C,
        0x1C,
        0x28,
        0x37,
        0x29,
        0x2C,
        0x30,
        0x31,
        0x34,
        0x34,
        0x34,
        0x1F,
        0x27,
        0x39,
        0x3D,
        0x38,
        0x32,
        0x3C,
        0x2E,
        0x33,
        0x34,
        0x32,
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x01,
        0x00,
        0x01,
        0x01,
        0x01,
        0x11,
        0x00,
        0xFF,
        0xC4,
        0x00,
        0x14,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0xFF,
        0xDA,
        0x00,
        0x08,
        0x01,
        0x01,
        0x00,
        0x00,
        0x3F,
        0x00,
        0x7F,
        0xFF,
        0xD9,
      ]);
    });

    setUp(() async {
      // Reset GetIt for each test
      await GetIt.instance.reset();

      // Setup test dependencies with mock OCR
      setupInjection();

      // Replace OCR repository with mock
      GetIt.instance.unregister<OCRRepository>();
      GetIt.instance.registerSingleton<OCRRepository>(MockOCRRepository());

      testDatabase = GetIt.instance<AppDatabase>();

      // Clean database before each test
      await testDatabase.delete(testDatabase.sheetMusic).go();
      await testDatabase.delete(testDatabase.tags).go();
      await testDatabase.delete(testDatabase.sheetMusicTags).go();
    });

    tearDownAll(() async {
      // Clean up test image
      if (await testImage.exists()) {
        await testImage.delete();
      }

      // Close database
      if (GetIt.instance.isRegistered<AppDatabase>()) {
        await GetIt.instance<AppDatabase>().close();
      }

      await GetIt.instance.reset();
    });

    testWidgets(
      'GIVEN user wants to add sheet music '
      'WHEN they complete the scan-to-save workflow '
      'THEN sheet music is saved to database and navigation returns',
      (WidgetTester tester) async {
        // ARRANGE - Launch the app
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to AddSheetPage from home
        // First, find and tap the "Add Sheet Music" button on HomePage
        final addButton =
            find.text('Add Sheet Music').or(find.byIcon(Icons.add));
        expect(addButton, findsAtLeast(1),
            reason: 'Add Sheet Music button should be present on home page');

        await tester.tap(addButton.first);
        await tester.pumpAndSettle();

        // Verify we're on AddSheetPage
        expect(find.text('Add Sheet Music'), findsOneWidget,
            reason: 'Should navigate to AddSheetPage');

        // ACT 1 - Tap Scan Sheet Music button to navigate to camera page
        final scanButton = find.text('Scan Sheet Music');
        expect(scanButton, findsOneWidget,
            reason: 'Scan Sheet Music button should be present');

        await tester.tap(scanButton);
        await tester.pumpAndSettle();

        // Note: We can't actually test the camera page interaction in integration tests
        // because it requires real hardware. The camera page would normally:
        // 1. Initialize camera
        // 2. Capture image
        // 3. Process with OCR
        // 4. Navigate to OCR review page

        // For a true end-to-end test, we would need to programmatically trigger
        // the OCR process. For now, we'll skip directly to testing the OCR review
        // and save workflow, which is where the critical navigation bug was fixed.

        // Instead, let's test from the perspective of the OCR review page onwards.
        // In a real scenario, the camera page would navigate to /ocr-review
        // We'll simulate that by using the router directly.

        // Navigate to OCR review page with test data
        appRouter.push(
          '/ocr-review',
          extra: {
            'imagePath': testImage.path,
            'detectedTitle': 'Moonlight Sonata',
            'detectedComposer': 'Ludwig van Beethoven',
            'confidence': 0.95,
          },
        );
        await tester.pumpAndSettle();

        // ACT 2 - Verify OCR review page loaded
        expect(find.text('Review & Edit'), findsOneWidget,
            reason: 'Should be on OCR Review page');

        // Verify detected values are displayed
        expect(find.text('Moonlight Sonata'), findsAtLeast(1),
            reason: 'Detected title should be shown');
        expect(find.text('Ludwig van Beethoven'), findsAtLeast(1),
            reason: 'Detected composer should be shown');

        // ACT 3 - Optionally edit the detected values
        final titleField =
            find.widgetWithText(TextFormField, 'Moonlight Sonata');
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Piano Sonata No. 14');
          await tester.pumpAndSettle();
        }

        // ACT 4 - Add tags
        final tagInput = find.byType(TextField).last;
        await tester.enterText(tagInput, 'Classical');
        await tester.pumpAndSettle();

        final addTagButton = find.text('Add');
        if (addTagButton.evaluate().isNotEmpty) {
          await tester.tap(addTagButton.first);
          await tester.pumpAndSettle();
        }

        // Verify tag was added
        expect(find.text('Classical'), findsAtLeast(1),
            reason: 'Tag should be added to the list');

        // ACT 5 - Save the sheet music
        final saveButton = find.text('Save');
        expect(saveButton, findsAtLeast(1),
            reason: 'Save button should be present');

        await tester.tap(saveButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ASSERT 1 - Verify success message appears
        expect(
          find.textContaining('successfully'),
          findsAtLeast(1),
          reason: 'Success message should appear after saving',
        );

        // ASSERT 2 - Verify navigation returned (critical - this was the P0 bug!)
        // The fix in commit a9f934e ensures context.pop() is called after save
        // We should not still be on the OCR Review page
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // We should have navigated back - verify we're no longer on Review page
        expect(
          find.text('Review & Edit'),
          findsNothing,
          reason: 'Should have navigated away from OCR Review page after save',
        );

        // ASSERT 3 - Verify data was saved to database
        final allSheets =
            await testDatabase.select(testDatabase.sheetMusic).get();
        expect(allSheets.length, 1,
            reason: 'Exactly one sheet music entry should be saved');

        final savedSheet = allSheets.first;
        expect(savedSheet.title, 'Piano Sonata No. 14',
            reason: 'Title should match edited value');
        expect(savedSheet.composer, 'Ludwig van Beethoven',
            reason: 'Composer should be saved');

        // ASSERT 4 - Verify tags were saved
        final savedTags = await testDatabase
            .select(testDatabase.sheetMusicTags)
            .join([
              innerJoin(
                testDatabase.tags,
                testDatabase.tags.id
                    .equalsExp(testDatabase.sheetMusicTags.tagId),
              )
            ])
            .where(testDatabase.sheetMusicTags.sheetId.equals(savedSheet.id))
            .get();

        expect(savedTags.length, greaterThan(0),
            reason:
                'At least one tag should be associated with the sheet music');
      },
    );

    testWidgets(
      'GIVEN user is on OCR review page '
      'WHEN they tap cancel '
      'THEN no data is saved and navigation returns',
      (WidgetTester tester) async {
        // ARRANGE - Launch app and navigate to OCR review
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        appRouter.push(
          '/ocr-review',
          extra: {
            'imagePath': testImage.path,
            'detectedTitle': 'Test Sheet',
            'detectedComposer': 'Test Composer',
            'confidence': 0.85,
          },
        );
        await tester.pumpAndSettle();

        // Verify we're on the review page
        expect(find.text('Review & Edit'), findsOneWidget);

        // Get initial sheet music count
        final initialCount =
            (await testDatabase.select(testDatabase.sheetMusic).get()).length;

        // ACT - Tap cancel/close button
        final closeButton = find.byIcon(Icons.close);
        expect(closeButton, findsOneWidget,
            reason: 'Close button should be present');

        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        // ASSERT - Verify no data was saved
        final finalCount =
            (await testDatabase.select(testDatabase.sheetMusic).get()).length;
        expect(finalCount, equals(initialCount),
            reason: 'No sheet music should be saved when canceling');

        // Verify navigation occurred
        expect(find.text('Review & Edit'), findsNothing,
            reason: 'Should have navigated away from review page');
      },
    );

    testWidgets(
      'GIVEN user enters invalid data '
      'WHEN they try to save '
      'THEN validation errors are shown and save is prevented',
      (WidgetTester tester) async {
        // ARRANGE - Launch app and navigate to OCR review with empty detected values
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        appRouter.push(
          '/ocr-review',
          extra: {
            'imagePath': testImage.path,
            'detectedTitle': '',
            'detectedComposer': '',
            'confidence': 0.50,
          },
        );
        await tester.pumpAndSettle();

        // Get initial count
        final initialCount =
            (await testDatabase.select(testDatabase.sheetMusic).get()).length;

        // ACT - Try to save without filling required fields
        final saveButton = find.text('Save');

        // Save button should be disabled when form is invalid
        final saveButtonWidget = tester.widget<TextButton>(saveButton.first);
        expect(saveButtonWidget.onPressed, isNull,
            reason: 'Save button should be disabled when form is invalid');

        // Try to fill with whitespace only (should still be invalid)
        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, '   ');
        await tester.pumpAndSettle();

        // Save should still be disabled
        final saveButtonWidget2 =
            tester.widget<TextButton>(find.text('Save').first);
        expect(saveButtonWidget2.onPressed, isNull,
            reason:
                'Save button should remain disabled with whitespace-only input');

        // ASSERT - Verify no data was saved
        final finalCount =
            (await testDatabase.select(testDatabase.sheetMusic).get()).length;
        expect(finalCount, equals(initialCount),
            reason: 'No data should be saved when validation fails');
      },
    );
  });
}
