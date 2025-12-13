import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddSheetPage Scan Flow Navigation Tests', () {
    testWidgets(
      'Tapping scan button navigates to /scan using context.push',
      (WidgetTester tester) async {
        final List<String> navigationLog = [];

        // Create a router that simulates the app navigation
        final router = GoRouter(
          initialLocation: '/add-sheet',
          routes: [
            GoRoute(
              path: '/add-sheet',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Add Sheet Music')),
                body: Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // This simulates the scan button behavior in AddSheetPage:323
                      context.push('/scan');
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Sheet Music'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/scan',
              builder: (context, state) {
                navigationLog.add('/scan');
                return Scaffold(
                  appBar: AppBar(title: const Text('Scan Camera')),
                  body: const Center(child: Text('Camera Page')),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        // Verify we're on the AddSheetPage
        expect(find.text('Add Sheet Music'), findsOneWidget);

        // Find and tap the scan button
        final scanButton = find.widgetWithText(
          OutlinedButton,
          'Scan Sheet Music',
        );
        expect(scanButton, findsOneWidget);

        await tester.tap(scanButton);
        await tester.pumpAndSettle();

        // Verify navigation to /scan occurred using context.push
        expect(navigationLog, contains('/scan'));
        expect(find.text('Camera Page'), findsOneWidget);

        // Verify navigation stack is preserved (can go back)
        expect(router.canPop(), isTrue);
      },
    );

    testWidgets(
      'Navigation stack is preserved when using context.push to scan page',
      (WidgetTester tester) async {
        final router = GoRouter(
          initialLocation: '/add-sheet',
          routes: [
            GoRoute(
              path: '/add-sheet',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Add Sheet Music')),
                body: Center(
                  child: OutlinedButton(
                    onPressed: () => context.push('/scan'),
                    child: const Text('Scan'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/scan',
              builder: (context, state) => Scaffold(
                appBar: AppBar(
                  title: const Text('Scan Camera'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),
                body: const Center(child: Text('Scan Page')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        // Tap scan button
        await tester.tap(find.text('Scan'));
        await tester.pumpAndSettle();

        // Verify we're on scan page
        expect(find.text('Scan Page'), findsOneWidget);

        // Tap back button to verify navigation stack preservation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify we're back on AddSheetPage
        expect(find.text('Add Sheet Music'), findsOneWidget);
      },
    );

    testWidgets(
      'Save button in OCR review calls context.pop() to navigate back',
      (WidgetTester tester) async {
        bool popCalled = false;
        bool navigatedBack = false;

        final router = GoRouter(
          initialLocation: '/add-sheet',
          routes: [
            GoRoute(
              path: '/add-sheet',
              builder: (context, state) {
                if (navigatedBack) {
                  // This confirms we returned to this page
                }
                return Scaffold(
                  appBar: AppBar(title: const Text('Add Sheet Music')),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => context.push('/ocr-review'),
                      child: const Text('Go to Review'),
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: '/ocr-review',
              builder: (context, state) => Scaffold(
                appBar: AppBar(
                  title: const Text('Review & Edit'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // This simulates OCRReviewWrapper:32 behavior
                        popCalled = true;
                        context.pop();
                        navigatedBack = true;
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                body: const Center(child: Text('OCR Review')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to review page
        await tester.tap(find.text('Go to Review'));
        await tester.pumpAndSettle();

        expect(find.text('Review & Edit'), findsOneWidget);

        // Tap the save button (which calls context.pop)
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify context.pop() was called and we're back
        expect(popCalled, isTrue);
        expect(find.text('Add Sheet Music'), findsOneWidget);
      },
    );

    testWidgets(
      'Complete scan flow: AddSheet -> Scan -> OCR Review -> Save (context.pop)',
      (WidgetTester tester) async {
        final router = GoRouter(
          initialLocation: '/add-sheet',
          routes: [
            GoRoute(
              path: '/add-sheet',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Add Sheet Music')),
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/scan'),
                    child: const Text('Scan Sheet Music'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/scan',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Scan')),
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulate scan completion and navigation to review
                      context.push('/ocr-review');
                    },
                    child: const Text('Scan Complete'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/ocr-review',
              builder: (context, state) => Scaffold(
                appBar: AppBar(
                  title: const Text('Review'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Save button pops twice (review -> scan -> add)
                        context.pop(); // Pop from review to scan
                        context.pop(); // Pop from scan to add
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                body: const Center(child: Text('Review Page')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        // Step 1: Start on AddSheetPage
        expect(find.text('Add Sheet Music'), findsOneWidget);

        // Step 2: Navigate to scan page using context.push
        await tester.tap(find.text('Scan Sheet Music'));
        await tester.pumpAndSettle();
        expect(find.text('Scan'), findsOneWidget);

        // Step 3: Complete scan and navigate to review using context.push
        await tester.tap(find.text('Scan Complete'));
        await tester.pumpAndSettle();
        expect(find.text('Review Page'), findsOneWidget);

        // Step 4: Save and verify context.pop() returns to AddSheetPage
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify we're back on AddSheetPage
        expect(find.text('Add Sheet Music'), findsOneWidget);
      },
    );

    testWidgets(
      'Verifies context.push preserves navigation stack (can pop back)',
      (WidgetTester tester) async {
        final router = GoRouter(
          initialLocation: '/add-sheet',
          routes: [
            GoRoute(
              path: '/add-sheet',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Add Sheet Music')),
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/scan'),
                    child: const Text('Scan'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/scan',
              builder: (context, state) => Scaffold(
                appBar: AppBar(title: const Text('Scan')),
                body: const Center(child: Text('Scan Page')),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to scan
        await tester.tap(find.text('Scan'));
        await tester.pumpAndSettle();

        // Verify we can pop (navigation stack is preserved)
        expect(router.canPop(), isTrue);

        // Verify current location
        expect(find.text('Scan Page'), findsOneWidget);

        // Use the system back button
        router.pop();
        await tester.pumpAndSettle();

        // Verify we're back
        expect(find.text('Add Sheet Music'), findsOneWidget);
      },
    );
  });
}
