import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adjustable scanning frame overlay for camera page
///
/// Provides an interactive frame that users can resize via:
/// - Pinch-to-zoom gestures
/// - Draggable corner handles
///
/// Frame size is persisted across sessions.
class AdjustableScanFrame extends StatefulWidget {
  final bool showGuideText;
  final VoidCallback? onFrameSizeChanged;

  const AdjustableScanFrame({
    super.key,
    this.showGuideText = true,
    this.onFrameSizeChanged,
  });

  @override
  State<AdjustableScanFrame> createState() => _AdjustableScanFrameState();
}

class _AdjustableScanFrameState extends State<AdjustableScanFrame> {
  // Frame dimensions
  double _frameWidth = 280.0;
  double _frameHeight = 380.0;

  // Constraints
  static const double _minWidth = 200.0;
  static const double _minHeight = 250.0;
  static const double _maxWidth = 600.0;
  static const double _maxHeight = 800.0;

  // Gesture state
  double _initialFrameWidth = 280.0;
  double _initialFrameHeight = 380.0;
  double _initialPinchScale = 1.0;

  // Corner handle state
  Offset? _dragOffset;
  _DragHandle? _activeDragHandle;

  // Shared preferences keys
  static const String _keyFrameWidth = 'scan_frame_width';
  static const String _keyFrameHeight = 'scan_frame_height';

  @override
  void initState() {
    super.initState();
    _loadFrameSize();
  }

  Future<void> _loadFrameSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _frameWidth = prefs.getDouble(_keyFrameWidth) ?? 280.0;
        _frameHeight = prefs.getDouble(_keyFrameHeight) ?? 380.0;
      });
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  Future<void> _saveFrameSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyFrameWidth, _frameWidth);
      await prefs.setDouble(_keyFrameHeight, _frameHeight);
      widget.onFrameSizeChanged?.call();
    } catch (e) {
      // Fail silently
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _initialFrameWidth = _frameWidth;
    _initialFrameHeight = _frameHeight;
    _initialPinchScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      // Pinch-to-zoom gesture
      final scaleDelta = details.scale / _initialPinchScale;
      setState(() {
        _frameWidth =
            (_initialFrameWidth * scaleDelta).clamp(_minWidth, _maxWidth);
        _frameHeight =
            (_initialFrameHeight * scaleDelta).clamp(_minHeight, _maxHeight);
      });
      _initialPinchScale = details.scale;
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _saveFrameSize();
  }

  void _handleCornerDragStart(DragStartDetails details, _DragHandle handle) {
    setState(() {
      _activeDragHandle = handle;
      _dragOffset = details.localPosition;
      _initialFrameWidth = _frameWidth;
      _initialFrameHeight = _frameHeight;
    });
  }

  void _handleCornerDragUpdate(DragUpdateDetails details) {
    if (_activeDragHandle == null) return;

    final delta = details.localPosition - (_dragOffset ?? Offset.zero);

    setState(() {
      switch (_activeDragHandle!) {
        case _DragHandle.topLeft:
          _frameWidth =
              (_initialFrameWidth - delta.dx * 2).clamp(_minWidth, _maxWidth);
          _frameHeight = (_initialFrameHeight - delta.dy * 2)
              .clamp(_minHeight, _maxHeight);
          break;
        case _DragHandle.topRight:
          _frameWidth =
              (_initialFrameWidth + delta.dx * 2).clamp(_minWidth, _maxWidth);
          _frameHeight = (_initialFrameHeight - delta.dy * 2)
              .clamp(_minHeight, _maxHeight);
          break;
        case _DragHandle.bottomLeft:
          _frameWidth =
              (_initialFrameWidth - delta.dx * 2).clamp(_minWidth, _maxWidth);
          _frameHeight = (_initialFrameHeight + delta.dy * 2)
              .clamp(_minHeight, _maxHeight);
          break;
        case _DragHandle.bottomRight:
          _frameWidth =
              (_initialFrameWidth + delta.dx * 2).clamp(_minWidth, _maxWidth);
          _frameHeight = (_initialFrameHeight + delta.dy * 2)
              .clamp(_minHeight, _maxHeight);
          break;
      }
    });
  }

  void _handleCornerDragEnd(DragEndDetails details) {
    setState(() {
      _activeDragHandle = null;
      _dragOffset = null;
    });
    _saveFrameSize();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main frame
            Container(
              width: _frameWidth,
              height: _frameHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.showGuideText
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Position cover page\nwithin frame',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pinch or drag corners to resize',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    )
                  : null,
            ),

            // Corner handles
            ..._buildCornerHandles(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerHandles() {
    return [
      // Top-left
      Positioned(
        left: -_frameWidth / 2 - 12,
        top: -_frameHeight / 2 - 12,
        child: _buildHandle(_DragHandle.topLeft),
      ),
      // Top-right
      Positioned(
        left: _frameWidth / 2 - 12,
        top: -_frameHeight / 2 - 12,
        child: _buildHandle(_DragHandle.topRight),
      ),
      // Bottom-left
      Positioned(
        left: -_frameWidth / 2 - 12,
        top: _frameHeight / 2 - 12,
        child: _buildHandle(_DragHandle.bottomLeft),
      ),
      // Bottom-right
      Positioned(
        left: _frameWidth / 2 - 12,
        top: _frameHeight / 2 - 12,
        child: _buildHandle(_DragHandle.bottomRight),
      ),
    ];
  }

  Widget _buildHandle(_DragHandle handle) {
    final isActive = _activeDragHandle == handle;

    return GestureDetector(
      onPanStart: (details) => _handleCornerDragStart(details, handle),
      onPanUpdate: _handleCornerDragUpdate,
      onPanEnd: _handleCornerDragEnd,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.drag_indicator,
          size: 12,
          color: isActive ? Colors.white : Colors.black.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Enum for corner drag handles
enum _DragHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
