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

  /// Refresh the sheet music list while preserving existing data
  Future<void> refresh() async {
    // If we already have data, mark as refreshing instead of loading
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(HomeLoaded(
        sheetMusicList: currentState.sheetMusicList,
        totalCount: currentState.totalCount,
        isRefreshing: true,
      ));
    } else {
      // If no data yet, show normal loading
      emit(const HomeLoading());
    }

    final result = await getAllSheetMusicUseCase();

    result.fold(
      (failure) => emit(HomeError(failure)),
      (sheetMusicList) => emit(
        HomeLoaded(
          sheetMusicList: sheetMusicList,
          totalCount: sheetMusicList.length,
          isRefreshing: false,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
