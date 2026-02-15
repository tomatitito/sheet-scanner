/// Cross-field auto-fill matcher for sheet music forms.
///
/// Watches filled form fields and auto-fills remaining fields when the
/// current criteria narrow to a single unambiguous match in the reference data.
library;

import 'composers.dart';
import 'composer_works.dart';

/// Enum tracking whether a field was set by the user or auto-filled.
enum FieldProvenance { empty, manual, autoFilled }

/// All matchable criteria from the form.
class MatchCriteria {
  final String? composer;
  final String? title;
  final int? difficulty;
  final String? instrumentation;
  final String? epoch;

  const MatchCriteria({
    this.composer,
    this.title,
    this.difficulty,
    this.instrumentation,
    this.epoch,
  });

  /// Whether any criteria are set.
  bool get hasAnyCriteria =>
      (composer != null && composer!.isNotEmpty) ||
      (title != null && title!.isNotEmpty) ||
      difficulty != null ||
      (instrumentation != null && instrumentation!.isNotEmpty) ||
      (epoch != null && epoch!.isNotEmpty);
}

/// A candidate match combining composer + work data.
class WorkCandidate {
  final String composerName;
  final String title;
  final int? difficulty;
  final String? instrumentation;
  final String? epoch;

  const WorkCandidate({
    required this.composerName,
    required this.title,
    this.difficulty,
    this.instrumentation,
    this.epoch,
  });
}

/// Result of an auto-fill match attempt.
class AutoFillResult {
  /// The single matched candidate, or null if zero or multiple matches.
  final WorkCandidate? uniqueMatch;

  /// Number of candidates that matched.
  final int candidateCount;

  const AutoFillResult({this.uniqueMatch, required this.candidateCount});

  /// Whether a unique match was found for auto-filling.
  bool get hasUniqueMatch => uniqueMatch != null;
}

/// Finds matching works from reference data based on form criteria.
///
/// Used to auto-fill form fields when the user's input narrows down to
/// a single unambiguous piece in the Zerluth/OpenOpus reference database.
class AutoFillMatcher {
  /// Finds all works matching the given criteria.
  ///
  /// Returns an [AutoFillResult] containing the unique match (if exactly one)
  /// and the total candidate count.
  AutoFillResult findMatch(MatchCriteria criteria) {
    if (!criteria.hasAnyCriteria) {
      return const AutoFillResult(candidateCount: 0);
    }

    final candidates = <WorkCandidate>[];

    // Determine which composers to search
    List<ComposerData> composersToSearch;
    if (criteria.composer != null && criteria.composer!.isNotEmpty) {
      // Filter to matching composers
      composersToSearch = ComposerLoader.searchComposers(criteria.composer!);
      if (composersToSearch.isEmpty) {
        return const AutoFillResult(candidateCount: 0);
      }
    } else {
      composersToSearch = ComposerLoader.composers;
    }

    // Check epoch filter against composer epoch if set
    for (final composer in composersToSearch) {
      if (criteria.epoch != null &&
          criteria.epoch!.isNotEmpty &&
          composer.epoch.toLowerCase() != 'unknown' &&
          composer.epoch.toLowerCase() != criteria.epoch!.toLowerCase()) {
        continue;
      }

      final works =
          ComposerWorksData.instance.getWorksInfoForComposer(composer.name);
      if (works.isEmpty) continue;

      for (final work in works) {
        // Apply title filter
        if (criteria.title != null && criteria.title!.isNotEmpty) {
          if (!work.title
              .toLowerCase()
              .contains(criteria.title!.toLowerCase())) {
            continue;
          }
        }

        // Apply difficulty filter
        if (criteria.difficulty != null) {
          if (work.difficulty != criteria.difficulty) {
            continue;
          }
        }

        // Apply instrumentation filter
        if (criteria.instrumentation != null &&
            criteria.instrumentation!.isNotEmpty) {
          if (work.instrumentation == null ||
              !work.instrumentation!
                  .toLowerCase()
                  .contains(criteria.instrumentation!.toLowerCase())) {
            continue;
          }
        }

        candidates.add(WorkCandidate(
          composerName: composer.name,
          title: work.title,
          difficulty: work.difficulty,
          instrumentation: work.instrumentation,
          epoch:
              composer.epoch != 'Unknown' ? composer.epoch.toLowerCase() : null,
        ));
      }
    }

    if (candidates.length == 1) {
      return AutoFillResult(
        uniqueMatch: candidates.first,
        candidateCount: 1,
      );
    }

    return AutoFillResult(candidateCount: candidates.length);
  }
}
