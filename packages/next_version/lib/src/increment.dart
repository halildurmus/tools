import 'package:conventional_commit/conventional_commit.dart';
import 'package:version/version.dart';

import 'config.dart';

/// Represents a semantic version increment derived from conventional commits.
///
/// A [VersionIncrement] describes how a version should change (major, minor,
/// patch, or pre-release) and provides logic for selecting and applying the
/// appropriate increment based on commit history and versioning rules.
enum VersionIncrement {
  /// A major increment, applied for backward-incompatible changes.
  ///
  /// Resets minor and patch numbers to zero (e.g., `1.2.3` → `2.0.0`).
  major,

  /// A minor increment, applied for backward-compatible features or significant
  /// improvements.
  ///
  /// Resets the patch number to zero (e.g., `1.2.3` → `1.3.0`).
  minor,

  /// A patch increment, applied for backward-compatible bug fixes or small
  /// improvements (e.g., `1.2.3` → `1.2.4`).
  patch,

  /// A pre-release increment, used to advance an existing pre-release version
  /// (e.g., `1.2.3-alpha.1` → `1.2.3-alpha.2`).
  preRelease;

  /// Determines the appropriate version increment for the given [commits].
  ///
  /// The result is calculated using the current version, the parsed
  /// conventional commits, and the rules defined in the provided [config].
  ///
  /// **Rules:**
  ///
  /// - **Pre-1.0 versions (`0.x.x`)**
  ///   - Breaking changes produce a [minor] increment.
  ///   - All non-breaking changes produce a [patch] increment, regardless of
  ///     commit type.
  ///
  /// - **Stable versions (`1.x.x` and above)**
  ///   - Breaking changes produce a [major] increment.
  ///   - Otherwise, the highest-priority increment mapped from commit types is
  ///     selected (`major > minor > patch > preRelease`).
  ///
  /// Returns `null` if none of the commits map to an increment.
  static VersionIncrement? calculate(
    Version currentVersion,
    List<ConventionalCommit> commits,
    VersioningConfig config,
  ) {
    if (commits.isEmpty) {
      throw ArgumentError.value(commits, 'commits', 'Commits cannot be empty.');
    }

    // Check for any breaking changes and handle according to version rules.
    if (commits.any((commit) => commit.isBreakingChange)) {
      return _handleBreakingChange(currentVersion);
    }

    // Collect all increments based on commit types.
    final increments = commits
        .map((commit) => config.incrementByCommitType[commit.type])
        .whereType<VersionIncrement>()
        .toList();
    if (increments.isEmpty) return null;

    // In `0.x.x` versions, only increment the patch version regardless of
    // commit types.
    if (currentVersion.major == 0) return VersionIncrement.patch;

    // Return the highest priority increment.
    return increments.reduce(_higherPriorityIncrement);
  }

  /// Handles breaking changes based on the given [version].
  ///
  /// For `0.x.x` versions, returns [minor], otherwise returns [major].
  static VersionIncrement _handleBreakingChange(Version version) =>
      version.major == 0 ? VersionIncrement.minor : VersionIncrement.major;

  /// Determines which increment has higher priority, with [major] taking
  /// precedence, followed by [minor], then [patch], and finally [preRelease].
  static VersionIncrement _higherPriorityIncrement(
    VersionIncrement a,
    VersionIncrement b,
  ) => a.index < b.index ? a : b;

  /// Applies the increment type to the given [version].
  Version applyTo(Version version) => switch (this) {
    VersionIncrement.major => version.incrementMajor(),
    VersionIncrement.minor => version.incrementMinor(),
    VersionIncrement.patch => version.incrementPatch(),
    VersionIncrement.preRelease => version.incrementPreRelease(),
  };
}
