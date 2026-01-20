# Source Field Feature Documentation

## Overview

The Source field feature allows users to categorize their sheet music by specifying where the music comes from or is stored. For example, a user might mark sheet music as coming from their "private" collection, their "music school", or any other custom source they define.

## Features

### 1. Source Field in Sheet Music

- **Location**: Available in both Add Sheet Music and Edit Sheet Music pages
- **Type**: Optional dropdown field
- **Validation**: Maximum 100 characters
- **Storage**: Stored in the `source` column of the `sheet_music_table`

### 2. Configurable Source Values

Users can manage their list of source values through an intuitive interface:

- **Default Source**: "private" (cannot be removed)
- **Add New Sources**: Users can add custom source values
- **Remove Sources**: Users can remove custom sources (except the default "private")
- **Persistent Storage**: Source values are stored in SharedPreferences

### 3. User Interface

#### Add/Edit Sheet Music Page

The Source dropdown appears after the Musical Key field and includes:
- Dropdown with all configured source values
- "None (optional)" option for when no source is needed
- "Manage Sources" button to add/remove source values

#### Manage Sources Dialog

- Text input field to add new sources
- "Add" button to save new sources
- List of existing sources with remove buttons
- Default "private" source is marked with a badge and cannot be removed

## Implementation Details

### Data Model

```dart
class SheetMusic {
  // ... other fields
  String? source;  // Optional source field
}
```

### Database Schema

- **Column**: `source TEXT`
- **Type**: Nullable text column
- **Migration**: Version 6 migration adds the column
- **Index**: Not indexed (optional field, not used for querying)

### Source Management Service

**File**: `lib/core/services/source_manager.dart`

The `SourceManager` class provides:
- `getSources()`: Get all configured source values
- `addSource(String)`: Add a new source value
- `removeSource(String)`: Remove a source value (except default)
- `ensureDefaults()`: Ensure "private" source exists
- `resetToDefaults()`: Reset to only "private" source

Sources are stored as JSON in SharedPreferences under the key `sheet_music_sources`.

### UI Components

**File**: `lib/features/sheet_music/presentation/widgets/source_dropdown.dart`

The `SourceDropdown` widget provides:
- Dropdown field with all configured sources
- "Manage Sources" button
- Dialog for adding/removing sources
- Real-time updates when sources are modified

## Usage Guide

### For Users

1. **Adding a Source Value**:
   - Open Add or Edit Sheet Music page
   - Click "Manage Sources" button below the Source dropdown
   - Enter a new source name (e.g., "music school")
   - Click "Add"
   - The new source will appear in the dropdown

2. **Assigning a Source to Sheet Music**:
   - Open Add or Edit Sheet Music page
   - Select a source from the Source dropdown
   - Save the sheet music entry

3. **Removing a Source Value**:
   - Click "Manage Sources" button
   - Find the source you want to remove
   - Click the delete icon next to it
   - Note: The "private" source cannot be removed

### For Developers

1. **Adding New Default Sources**:
   
   Edit `lib/core/services/source_manager.dart`:
   ```dart
   static const String _defaultSource = 'private';
   static const List<String> _defaultSources = ['private', 'school', 'library'];
   ```

2. **Modifying Validation Rules**:

   Edit the Cubit files to change the maximum length:
   ```dart
   if (source != null && source.length > 100) {
     errors['source'] = 'Source must not exceed 100 characters';
   }
   ```

3. **Customizing the UI**:

   The Source dropdown is implemented in:
   - `lib/features/sheet_music/presentation/widgets/source_dropdown.dart`
   - `lib/features/sheet_music/presentation/pages/add_sheet_page.dart`
   - `lib/features/sheet_music/presentation/pages/edit_sheet_page.dart`

## Database Migration

The source field was added in database schema version 6:

```dart
if (from < 6) {
  // Migration from v5 to v6: Add source column
  await customStatement(
    'ALTER TABLE sheet_music_table ADD COLUMN source TEXT',
  );
}
```

Existing data will have `null` values for the source field, which is acceptable since it's an optional field.

## Testing

To test the feature:

1. **Manual Testing**:
   - Add a new sheet music entry with a source
   - Edit an existing entry and add/change the source
   - Add custom source values via "Manage Sources"
   - Remove custom source values
   - Verify the default "private" source cannot be removed

2. **Data Persistence**:
   - Add source values
   - Close and reopen the app
   - Verify source values persist

3. **Database Migration**:
   - Test upgrading from schema version 5 to 6
   - Verify existing data is preserved
   - Verify new source column is added

## Future Enhancements

Potential improvements for the future:

1. **Search by Source**: Add ability to filter/search sheet music by source
2. **Source Statistics**: Show how many pieces are in each source
3. **Source Colors**: Allow users to assign colors to sources
4. **Import/Export Sources**: Allow backing up and restoring source configurations
5. **Source Templates**: Provide pre-defined source templates for common use cases

## Related Files

- **Domain Entity**: `lib/features/sheet_music/domain/entities/sheet_music.dart`
- **Database Schema**: `lib/core/database/database.dart`
- **Data Model**: `lib/features/sheet_music/data/models/sheet_music_model.dart`
- **Datasource**: `lib/features/sheet_music/data/datasources/sheet_music_local_datasource.dart`
- **Source Manager**: `lib/core/services/source_manager.dart`
- **Source Dropdown Widget**: `lib/features/sheet_music/presentation/widgets/source_dropdown.dart`
- **Add Sheet Cubit**: `lib/features/sheet_music/presentation/cubit/add_sheet_cubit.dart`
- **Edit Sheet Cubit**: `lib/features/sheet_music/presentation/cubit/edit_sheet_cubit.dart`
- **Add Sheet Page**: `lib/features/sheet_music/presentation/pages/add_sheet_page.dart`
- **Edit Sheet Page**: `lib/features/sheet_music/presentation/pages/edit_sheet_page.dart`

## Version History

- **v1.0.0** (2026-01-20): Initial implementation of the Source field feature
  - Added source field to data model
  - Implemented SourceManager service
  - Created SourceDropdown UI widget
  - Added database migration (schema v6)
  - Updated Add/Edit pages and Cubits
