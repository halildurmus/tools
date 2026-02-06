import 'package:conventional_commit/conventional_commit.dart';
import 'package:version/version.dart';

import 'config.dart';
import 'increment.dart';

/// Computes the next semantic version from conventional commit messages.
final class VersionCalculator {
  /// Calculates the next version based on the current version and a list of
  /// conventional commit messages.
  ///
  /// Commit messages are parsed using the Conventional Commit specification and
  /// mapped to version increments according to the provided [config].
  ///
  /// **Behavior:**
  ///
  /// - If [commitMessages] is empty, [currentVersion] is returned unchanged.
  /// - Commit messages that cannot be parsed as conventional commits are
  ///   ignored.
  /// - If no applicable conventional commits are found, the [currentVersion] is
  ///   returned unchanged.
  /// - If multiple applicable commits are present, the highest-priority version
  ///   increment is applied.
  /// - Breaking changes always take precedence over non-breaking changes.
  ///
  /// **Versioning Rules:**
  /// - **Pre-1.0 versions (`0.x.x`)**
  ///   - Breaking changes result in a _minor_ increment.
  ///   - All non-breaking changes result in a _patch_ increment, regardless of
  ///     commit type.
  ///
  /// - **Stable versions (`1.x.x` and above)**
  ///   - Breaking changes result in a _major_ increment.
  ///   - Non-breaking changes use the highest-priority increment defined by the
  ///     configuration.
  static Version nextVersion(
    Version currentVersion,
    List<String> commitMessages,
    VersioningConfig config,
  ) {
    if (commitMessages.isEmpty) return currentVersion;
    final commits = commitMessages
        .map(ConventionalCommit.tryParse)
        .whereType<ConventionalCommit>()
        .toList();
    if (commits.isEmpty) return currentVersion;
    final versionIncrement = VersionIncrement.calculate(
      currentVersion,
      commits,
      config,
    );
    if (versionIncrement == null) return currentVersion;
    return versionIncrement.applyTo(currentVersion);
  }
}

/// Convenience API for calculating the next semantic version from conventional
/// commit messages.
///
/// This extension provides an instance-level wrapper around
/// [VersionCalculator], allowing version computation to be expressed fluently
/// from an existing [Version] value.
///
/// ```dart
/// final commits = [...]; // List of conventional commit messages
/// final nextVersion = Version.parse('1.2.3').nextVersion(commits);
/// ```
///
/// The behavior and versioning rules are identical to those of
/// [VersionCalculator]; see its documentation for full details.
extension VersionExtension on Version {
  /// Calculates the next version based on the current version and a list of
  /// commit messages, applying the specified [config].
  Version nextVersion(
    List<String> commitMessages, {
    VersioningConfig config = VersioningConfig.defaultConfig,
  }) => VersionCalculator.nextVersion(this, commitMessages, config);
}
