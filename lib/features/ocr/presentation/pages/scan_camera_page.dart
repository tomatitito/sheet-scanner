import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/ocr/presentation/cubit/ocr_scan_cubit.dart';
import 'package:sheet_scanner/features/ocr/presentation/cubit/ocr_scan_state.dart';
import 'package:sheet_scanner/features/ocr/presentation/widgets/adjustable_scan_frame.dart';

/// Mobile camera scanning page for sheet music covers
/// Allows user to capture or select image, then process with OCR
class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late OCRScanCubit _ocrScanCubit;
  late List<CameraDescription> _cameras;
  late ImagePicker _imagePicker;

  final _logger = Logger('ScanCameraPage');

  bool _isCameraInitialized = false;
  bool _showGrid = false;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _imagePicker = ImagePicker();
    _ocrScanCubit = getIt<OCRScanCubit>();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        _logger.warning('No cameras available');
        if (!mounted) return;
        _showError('No camera available on this device');
        return;
      }

      final firstCamera = _cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      _ocrScanCubit.initializeCamera();

      setState(() {
        _isCameraInitialized = true;
      });

      _logger.info('Camera initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize camera: $e');
      if (!mounted) return;
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized) return;

    try {
      _logger.info('Capturing photo...');

      final image = await _cameraController!.takePicture();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage =
          await File(image.path).copy('${tempDir.path}/$fileName');

      if (!mounted) return;

      _logger.info('Photo captured: ${savedImage.path}');

      // Process the image with OCR
      _ocrScanCubit.captureAndProcess(savedImage.path);
    } catch (e) {
      _logger.severe('Failed to capture photo: $e');
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      _logger.info('Picking image from gallery...');

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        _logger.info('Image selected: ${pickedFile.path}');
        if (!mounted) return;
        _ocrScanCubit.captureAndProcess(pickedFile.path);
      }
    } catch (e) {
      _logger.severe('Failed to pick image: $e');
      _showError('Failed to pick image: $e');
    }
  }

  void _toggleGrid() {
    setState(() {
      _showGrid = !_showGrid;
    });
  }

  Future<void> _toggleFlash() async {
    if (!_isCameraInitialized) return;

    try {
      final newFlashMode = _flashEnabled ? FlashMode.off : FlashMode.always;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _flashEnabled = !_flashEnabled;
      });
      _logger.info('Flash toggled: $_flashEnabled');
    } catch (e) {
      _logger.warning('Failed to toggle flash: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _close() {
    _ocrScanCubit.reset();
    context.pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isCameraInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _cameraController?.resumePreview();
      case AppLifecycleState.paused:
        _cameraController?.pausePreview();
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.inactive:
        _cameraController?.pausePreview();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _ocrScanCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<OCRScanCubit, OCRScanState>(
        bloc: _ocrScanCubit,
        listener: (context, state) {
          state.when(
            initial: () {},
            cameraReady: () {},
            capturing: () {
              // Show processing indicator
            },
            processing: (imagePath, progress, currentOperation) {
              // User can see progress
            },
            ocrComplete: (imagePath, extractedText, confidence) async {
              // Navigate to review page with OCR results
              _logger.info('OCR complete, navigating to review');
              // Parse the extracted text to extract title and composer
              // Format: "Title\nComposer" or just look for lines
              final lines = extractedText
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .toList();
              final detectedTitle = lines.isNotEmpty ? lines.first : '';
              final detectedComposer = lines.length > 1 ? lines[1] : '';

              if (!mounted) {
                _logger.warning(
                    'Widget not mounted, skipping OCR review navigation');
                return;
              }

              _logger.info(
                  'Pushing to /ocr-review with detectedTitle="$detectedTitle", detectedComposer="$detectedComposer"');
              final result = await context.push<Map<String, dynamic>>(
                '/ocr-review',
                extra: {
                  'imagePath': imagePath,
                  'detectedTitle': detectedTitle,
                  'detectedComposer': detectedComposer,
                  'confidence': confidence,
                },
              );

              // If user confirmed OCR results, pop back to AddSheetPage with the data
              if (result != null) {
                if (!mounted) {
                  _logger.warning(
                      'Widget not mounted after OCR review, cannot pop with result');
                  return;
                }
                _logger.info(
                    'OCR review returned data: ${result.keys.join(", ")}. Popping back to AddSheetPage.');
                // ignore: use_build_context_synchronously
                context.pop(result);
              } else {
                _logger.info('OCR review returned null (user cancelled)');
              }
            },
            error: (failure, imagePath) {
              _showError(failure.message);
            },
            permissionDenied: () {
              _showPermissionDialog();
            },
          );
        },
        child: BlocBuilder<OCRScanCubit, OCRScanState>(
          bloc: _ocrScanCubit,
          builder: (context, state) {
            return Stack(
              children: [
                // Camera preview
                if (_isCameraInitialized)
                  CameraPreview(_cameraController!)
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // Top bar with close and settings buttons
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            onPressed: _close,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            color: Colors.white,
                            onPressed: () {
                              // Open settings modal
                            },
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Adjustable scanning frame overlay
                if (_isCameraInitialized &&
                    !state.maybeWhen(
                      processing: (imagePath, progress, currentOperation) =>
                          true,
                      orElse: () => false,
                    ))
                  const AdjustableScanFrame(
                    showGuideText: true,
                  ),

                // Grid overlay (when enabled)
                if (_showGrid &&
                    _isCameraInitialized &&
                    !state.maybeWhen(
                      processing: (imagePath, progress, currentOperation) =>
                          true,
                      orElse: () => false,
                    ))
                  Center(
                    child: CustomPaint(
                      painter: _GridPainter(),
                      size: Size.infinite,
                    ),
                  ),

                // Processing overlay
                if (state.maybeWhen(
                  processing: (imagePath, progress, currentOperation) => true,
                  orElse: () => false,
                ))
                  Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            state.maybeWhen(
                              processing:
                                  (imagePath, progress, currentOperation) =>
                                      currentOperation ?? 'Processing...',
                              orElse: () => 'Processing...',
                            ),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: state.maybeWhen(
                                processing:
                                    (imagePath, progress, currentOperation) =>
                                        progress,
                                orElse: () => 0.0,
                              ),
                              minHeight: 4,
                              backgroundColor: Colors.grey.shade700,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          // Control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.info_outline,
                                label: 'Tip',
                                onPressed: () {
                                  _showTipsDialog();
                                },
                              ),
                              _buildControlButton(
                                icon:
                                    _showGrid ? Icons.grid_on : Icons.grid_off,
                                label: 'Grid',
                                onPressed: _toggleGrid,
                              ),
                              _buildControlButton(
                                icon: Icons.photo_library,
                                label: 'Gallery',
                                onPressed: _pickFromGallery,
                              ),
                              _buildControlButton(
                                icon: _flashEnabled
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                label: 'Flash',
                                onPressed: _toggleFlash,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Capture button
                          if (!state.maybeWhen(
                            processing:
                                (imagePath, progress, currentOperation) => true,
                            orElse: () => false,
                          ))
                            GestureDetector(
                              onTap: _capturePhoto,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: Colors.white,
          onPressed: onPressed,
          iconSize: 24,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanning Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Use good lighting'),
            SizedBox(height: 8),
            Text('• Position cover page squarely'),
            SizedBox(height: 8),
            Text('• Avoid glare and shadows'),
            SizedBox(height: 8),
            Text('• Keep the camera steady'),
            SizedBox(height: 8),
            Text('• Focus on the title and composer'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Access Required'),
        content: const Text(
          'This app needs camera access to scan sheet music covers.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppSettings() async {
    // Open the app settings page so user can grant camera permissions
    try {
      await openAppSettings();
      _logger.info('Opened app settings for permissions');
    } catch (e) {
      _logger.severe('Failed to open app settings: $e');
      if (!mounted) return;
      _showError('Failed to open settings: $e');
    }
  }
}

/// Custom painter for grid overlay
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    const gridDivisions = 3;
    final cellWidth = size.width / gridDivisions;
    final cellHeight = size.height / gridDivisions;

    // Vertical lines
    for (int i = 1; i < gridDivisions; i++) {
      canvas.drawLine(
        Offset(cellWidth * i, 0),
        Offset(cellWidth * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < gridDivisions; i++) {
      canvas.drawLine(
        Offset(0, cellHeight * i),
        Offset(size.width, cellHeight * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
