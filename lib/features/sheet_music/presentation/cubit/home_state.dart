import 'package:equatable/equatable.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Base state for HomeCubit
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state while fetching sheet music
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Success state with loaded sheet music data
class HomeLoaded extends HomeState {
  final List<SheetMusic> sheetMusicList;
  final int totalCount;

  const HomeLoaded({
    required this.sheetMusicList,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [sheetMusicList, totalCount];
}

/// Error state with failure details
class HomeError extends HomeState {
  final Failure failure;

  const HomeError(this.failure);

  @override
  List<Object?> get props => [failure];
}
