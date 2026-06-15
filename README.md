# Sheet Scanner

A local-first Flutter app for cataloging sheet music with OCR scanning,
search, tagging, and backup/import tools.

## Current Capabilities

- 📚 **Library management**: Add, browse, edit, view, and delete sheet music
  entries.
- 🧾 **Rich metadata**: Track title, composer, opus/catalog number, musical
  key, source, notes, difficulty, instrumentation, epoch, tags, and image
  paths.
- 🔍 **Search and filtering**: SQLite FTS5 full-text search, advanced filters,
  composer search, tag filters, and sorting.
- 🏷️ **Tags**: Create/manage tags, assign them to sheets, and use tag
  suggestions.
- 📸 **OCR scanning**: Capture/select images and extract title/composer text via
  ML Kit, with an OCR review flow before saving.
- 🎙️ **Voice input**: Dictation support with platform speech recognition and
  Whisper/OpenAI Whisper service code paths.
- 💾 **Backup and import**: Export database, JSON metadata, or ZIP archives;
  import backups or replace the local database.
- 🖥️ **Responsive UI**: Mobile and desktop-oriented layouts,
  keyboard/accessibility helpers, and settings.

## Platform Notes

The app targets Flutter desktop, mobile, and web builds. Core catalog, search,
and backup features are local-first. Camera/OCR and voice features depend on
platform permissions and plugin support; ML Kit OCR is intended for mobile
devices.

## Getting Started

This project uses **FVM**. Run Flutter/Dart commands through `fvm`.

```bash
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
fvm flutter run -d macos      # desktop
fvm flutter run -d chrome     # web
fvm flutter run -d ios        # iOS simulator/device
fvm flutter run -d android    # Android emulator/device
```

## Development Commands

```bash
fvm flutter analyze
fvm flutter test
fvm dart format lib test integration_test
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Build examples:

```bash
fvm flutter build apk
fvm flutter build ios
fvm flutter build macos
fvm flutter build web
```

## Architecture

The codebase follows Clean Architecture with feature slices under
`lib/features` and shared infrastructure under `lib/core`.

```text
lib/
├── core/                  # database, DI, routing, services, storage, utilities
├── data/                  # bundled composer/repertoire data and matching helpers
├── features/
│   ├── sheet_music/       # catalog CRUD, metadata, voice input
│   ├── search/            # FTS search, advanced filters, tag management
│   ├── ocr/               # camera/gallery scan, OCR processing, review flow
│   ├── backup/            # export/import/replace database workflows
│   └── settings/          # app and voice settings UI
└── main.dart
```

Each feature is split into:

- **domain**: entities, repository contracts, use cases
- **data**: datasources, repository implementations, models/services
- **presentation**: pages, widgets, cubits/states

State management uses **flutter_bloc/Cubit**, dependency injection uses
**get_it**, navigation uses **go_router**, persistence uses **Drift/SQLite**
with FTS5, and immutable models/states are generated with **Freezed** where
applicable.

## Testing

Unit tests live in `test/`; integration flows live in `integration_test/`.

```bash
fvm flutter test
fvm flutter test integration_test
```
