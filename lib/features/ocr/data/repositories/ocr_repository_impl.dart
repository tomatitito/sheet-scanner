import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:sheet_scanner/features/ocr/domain/repositories/ocr_repository.dart';

/// Implementation of OCRRepository using ML Kit for text recognition.
/// TODO: Complete implementation with actual OCR logic.
class OCRRepositoryImpl implements OCRRepository {
  final OCRLocalDataSource localDataSource;

  OCRRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> isOCRAvailable() async {
    try {
      final available = await localDataSource.isOCRAvailable();
      return Right(available);
    } catch (e) {
      return Left(PlatformFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OCRResult>> recognizeText(String imagePath) async {
    try {
      final (text, confidence) = await localDataSource.recognizeText(imagePath);
      return Right(OCRResult(text: text, confidence: confidence));
    } on Exception catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OCRResult>>> recognizeTextBatch(
    List<String> imagePaths,
  ) async {
    try {
      final results = await localDataSource.recognizeTextBatch(imagePaths);
      return Right(
        results.map((result) => OCRResult(text: result.$1, confidence: result.$2)).toList(),
      );
    } on Exception catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }
}
