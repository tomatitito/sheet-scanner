import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/ocr_review_page.dart';

/// Wrapper page to adapt GoRouter parameters to OCRReviewPage
class OCRReviewWrapper extends StatelessWidget {
  final String imagePath;
  final String detectedTitle;
  final String detectedComposer;
  final double confidence;

  const OCRReviewWrapper({
    super.key,
    required this.imagePath,
    required this.detectedTitle,
    required this.detectedComposer,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return OCRReviewPage(
      detectedTitle: detectedTitle,
      detectedComposer: detectedComposer,
      confidence: confidence,
      capturedImage: File(imagePath),
      onSuccess: () {
        // Navigate back using GoRouter to avoid context issues
        if (context.mounted) {
          context.pop();
        }
      },
      onClose: () {
        // Navigate back using GoRouter
        if (context.mounted) {
          context.pop();
        }
      },
    );
  }
}
