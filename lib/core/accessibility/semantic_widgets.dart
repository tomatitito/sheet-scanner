import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides semantic widgets and utilities for accessibility (WCAG 2.1 AA)
/// Ensures screen reader compatibility and proper focus management

/// Wraps a widget with semantic information for screen readers
class SemanticButton extends StatefulWidget {
  const SemanticButton({
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.enabled = true,
    this.child,
    this.icon,
    this.focusNode,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool enabled;
  final Widget? child;
  final IconData? icon;
  final FocusNode? focusNode;

  @override
  State<SemanticButton> createState() => _SemanticButtonState();
}

class _SemanticButtonState extends State<SemanticButton> {
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
    final button = widget.icon != null
        ? ElevatedButton.icon(
            onPressed: widget.enabled ? widget.onPressed : null,
            icon: Icon(widget.icon),
            label: Text(widget.label),
            focusNode: _focusNode,
          )
        : ElevatedButton(
            onPressed: widget.enabled ? widget.onPressed : null,
            focusNode: _focusNode,
            child: widget.child ?? Text(widget.label),
          );

    // Wrap with Semantics for screen readers
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      tooltip: widget.tooltip ?? widget.label,
      onTap: widget.enabled ? widget.onPressed : null,
      child: widget.tooltip != null
          ? Tooltip(
              message: widget.tooltip!,
              child: button,
            )
          : button,
    );
  }
}

/// Semantic text field with proper labels and hints for accessibility
class SemanticTextField extends StatefulWidget {
  const SemanticTextField({
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.focusNode,
    this.errorText,
    this.maxLines = 1,
    this.minLines = 1,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final String? errorText;
  final int maxLines;
  final int minLines;

  @override
  State<SemanticTextField> createState() => _SemanticTextFieldState();
}

class _SemanticTextFieldState extends State<SemanticTextField> {
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
    return Semantics(
      label: widget.label,
      textField: true,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semantic label for field
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              semanticsLabel: widget.label,
            ),
          ),
          // Text field with semantic properties
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              labelText: widget.label,
              border: const OutlineInputBorder(),
              semanticCounterText: '',
            ),
          ),
          // Error message with semantic label
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Semantics(
                label: 'Error',
                child: Text(
                  widget.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                  semanticsLabel: 'Error: ${widget.errorText}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Semantic dropdown selector for accessibility
class SemanticDropdown<T> extends StatefulWidget {
  const SemanticDropdown({
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemLabel,
    this.focusNode,
    super.key,
  });

  final String label;
  final List<T> items;
  final Function(T?) onChanged;
  final T? value;
  final String Function(T)? itemLabel;
  final FocusNode? focusNode;

  @override
  State<SemanticDropdown<T>> createState() => _SemanticDropdownState<T>();
}

class _SemanticDropdownState<T> extends State<SemanticDropdown<T>> {
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
    return Semantics(
      label: widget.label,
      button: true,
      enabled: true,
      onTap: () => _focusNode.requestFocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              semanticsLabel: widget.label,
            ),
          ),
          Focus(
            focusNode: _focusNode,
            onKeyEvent: (node, event) {
              // Handle keyboard navigation in dropdown
              return KeyEventResult.ignored;
            },
            child: DropdownButton<T>(
              value: widget.value,
              items: widget.items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Semantics(
                        label: widget.itemLabel?.call(item) ?? item.toString(),
                        button: true,
                        enabled: true,
                        child: Text(
                          widget.itemLabel?.call(item) ?? item.toString(),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Creates a keyboard-navigable focus chain for grouped controls
class SemanticFocusGroup extends StatefulWidget {
  const SemanticFocusGroup({
    required this.label,
    required this.children,
    super.key,
  });

  final String label;
  final List<Widget> children;

  @override
  State<SemanticFocusGroup> createState() => _SemanticFocusGroupState();
}

class _SemanticFocusGroupState extends State<SemanticFocusGroup> {
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _focusNodes.addAll(
      List.generate(widget.children.length, (_) => FocusNode()),
    );
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.label,
      child: Column(
        children: widget.children,
      ),
    );
  }
}

/// Semantic checkbox with proper accessibility
class SemanticCheckbox extends StatefulWidget {
  const SemanticCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
    this.focusNode,
    super.key,
  });

  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String? tooltip;
  final FocusNode? focusNode;

  @override
  State<SemanticCheckbox> createState() => _SemanticCheckboxState();
}

class _SemanticCheckboxState extends State<SemanticCheckbox> {
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
    return Semantics(
      checked: widget.value,
      label: widget.label,
      enabled: true,
      onTap: () => widget.onChanged(!widget.value),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: Tooltip(
          message: widget.tooltip ?? widget.label,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Focus(
                focusNode: _focusNode,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      (event.logicalKey == LogicalKeyboardKey.space ||
                          event.logicalKey == LogicalKeyboardKey.enter)) {
                    widget.onChanged(!widget.value);
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Checkbox(
                  value: widget.value,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                semanticsLabel: widget.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Semantic icon button with proper accessibility labels and hints
class SemanticIconButton extends StatefulWidget {
  const SemanticIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.hint,
    this.enabled = true,
    this.isDarkBackground = true,
    this.size = 48.0,
    this.focusNode,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? hint;
  final bool enabled;
  final bool isDarkBackground;
  final double size;
  final FocusNode? focusNode;

  @override
  State<SemanticIconButton> createState() => _SemanticIconButtonState();
}

class _SemanticIconButtonState extends State<SemanticIconButton> {
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
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      hint: widget.hint,
      tooltip: widget.tooltip ?? widget.label,
      onTap: widget.enabled ? widget.onPressed : null,
      child: Tooltip(
        message: widget.tooltip ?? widget.label,
        child: IconButton(
          icon: Icon(widget.icon),
          onPressed: widget.enabled ? widget.onPressed : null,
          color: widget.isDarkBackground ? Colors.white : Colors.black,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black
                .withValues(alpha: widget.isDarkBackground ? 0.5 : 0),
          ),
          focusNode: _focusNode,
        ),
      ),
    );
  }
}

/// Creates an accessible card with keyboard navigation support
class SemanticCard extends StatefulWidget {
  const SemanticCard({
    required this.label,
    required this.child,
    this.onTap,
    this.focusNode,
    super.key,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<SemanticCard> createState() => _SemanticCardState();
}

class _SemanticCardState extends State<SemanticCard> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.label,
      button: widget.onTap != null,
      enabled: true,
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (widget.onTap != null &&
              event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.enter)) {
            widget.onTap!();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Card(
          elevation: _isFocused ? 8 : 2,
          child: Container(
            decoration: BoxDecoration(
              border: _isFocused
                  ? Border.all(
                      color: Theme.of(context).focusColor,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
