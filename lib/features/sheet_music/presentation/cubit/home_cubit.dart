import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'home_state.dart';

/// Cubit for managing home/dashboard screen state
/// Handles loading sheet music library data
class HomeCubit extends Cubit<HomeState> {
  final GetAllSheetMusicUseCase getAllSheetMusicUseCase;

  HomeCubit({required this.getAllSheetMusicUseCase})
      : super(const HomeInitial());

  /// Load all sheet music from the library
  Future<void> loadSheetMusic() async {
    emit(const HomeLoading());

    final result = await getAllSheetMusicUseCase();

    result.fold(
      (failure) => emit(HomeError(failure)),
      (sheetMusicList) => emit(
        HomeLoaded(
          sheetMusicList: sheetMusicList,
          totalCount: sheetMusicList.length,
        ),
      ),
    );
  }

  /// Refresh the sheet music list
  Future<void> refresh() => loadSheetMusic();
}
