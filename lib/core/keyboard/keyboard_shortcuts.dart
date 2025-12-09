import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global keyboard shortcuts handler for the sheet scanner app.
///
/// Manages keyboard events and executes corresponding actions across
/// the application with WCAG 2.1 AA compliance.
class KeyboardShortcuts {
  /// Callback types for keyboard actions
  static const String saveAction = 'save';
  static const String newItemAction = 'new_item';
  static const String searchAction = 'search';
  static const String escapeAction = 'escape';
  static const String deleteAction = 'delete';
  static const String editAction = 'edit';

  /// Platform-specific shortcut modifiers
  static bool isMacOS(TargetPlatform platform) {
    return platform == TargetPlatform.macOS;
  }

  static String getPlatformModifierLabel(TargetPlatform platform) {
    return isMacOS(platform) ? 'Cmd' : 'Ctrl';
  }

  /// Get standard keyboard shortcuts for the platform
  static Map<String, String> getStandardShortcuts(TargetPlatform platform) {
    final mod = getPlatformModifierLabel(platform);
    return {
      'Save': '$mod+S',
      'New Item': '$mod+N',
      'Search': '$mod+F',
      'Close': 'Escape',
      'Delete': 'Delete',
      'Edit': 'Enter',
      'Select All': '$mod+A',
      'Deselect All': '$mod+Shift+A',
    };
  }
}

/// Widget that provides keyboard event handling and shortcuts
class KeyboardShortcutsHandler extends StatefulWidget {
  const KeyboardShortcutsHandler({
    required this.child,
    required this.onShortcut,
    this.focusNode,
    super.key,
  });

  final Widget child;
  final Function(String actionKey) onShortcut;
  final FocusNode? focusNode;

  @override
  State<KeyboardShortcutsHandler> createState() =>
      _KeyboardShortcutsHandlerState();
}

class _KeyboardShortcutsHandlerState extends State<KeyboardShortcutsHandler> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    // Cmd/Ctrl+S: Save
    if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyS) {
      widget.onShortcut(KeyboardShortcuts.saveAction);
      return KeyEventResult.handled;
    }

    // Cmd/Ctrl+N: New Item
    if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyN) {
      widget.onShortcut(KeyboardShortcuts.newItemAction);
      return KeyEventResult.handled;
    }

    // Cmd/Ctrl+F: Search
    if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyF) {
      widget.onShortcut(KeyboardShortcuts.searchAction);
      return KeyEventResult.handled;
    }

    // Escape: Close/Cancel
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onShortcut(KeyboardShortcuts.escapeAction);
      return KeyEventResult.handled;
    }

    // Delete: Delete item
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      widget.onShortcut(KeyboardShortcuts.deleteAction);
      return KeyEventResult.handled;
    }

    // Enter: Edit/Open
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onShortcut(KeyboardShortcuts.editAction);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

/// Helper widget for keyboard navigation within lists
/// Provides arrow key navigation and enter to select
class KeyboardNavigableList extends StatefulWidget {
  const KeyboardNavigableList({
    required this.items,
    required this.onItemSelected,
    required this.itemBuilder,
    this.onEscape,
    super.key,
  });

  final List<dynamic> items;
  final Function(dynamic item, int index) onItemSelected;
  final Widget Function(
          BuildContext context, dynamic item, int index, bool isFocused)
      itemBuilder;
  final VoidCallback? onEscape;

  @override
  State<KeyboardNavigableList> createState() => _KeyboardNavigableListState();
}

class _KeyboardNavigableListState extends State<KeyboardNavigableList> {
  int _selectedIndex = 0;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final isFocused = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onItemSelected(widget.items[index], index);
            },
            child: widget.itemBuilder(
              context,
              widget.items[index],
              index,
              isFocused,
            ),
          );
        },
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Arrow Down: Move selection down
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_selectedIndex < widget.items.length - 1) {
        setState(() {
          _selectedIndex++;
        });
      }
      return KeyEventResult.handled;
    }

    // Arrow Up: Move selection up
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_selectedIndex > 0) {
        setState(() {
          _selectedIndex--;
        });
      }
      return KeyEventResult.handled;
    }

    // Enter: Select current item
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onItemSelected(
        widget.items[_selectedIndex],
        _selectedIndex,
      );
      return KeyEventResult.handled;
    }

    // Escape: Close
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
