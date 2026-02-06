import 'package:checks/checks.dart';
import 'package:next_version/next_version.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('VersionCalculator', () {
    test('applies major increment for breaking change on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = ['feat!: breaking API change'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('2.0.0'));
    });

    test('applies minor increment for feature commit on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });

    test('applies patch increment for fix commit on 1.x.x versions', () {
      final version = Version.parse('1.2.3');
      const commits = ['fix: bug fix'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });

    test('applies minor increment for breaking change on 0.x.x versions', () {
      final version = Version.parse('0.2.3');
      const commits = ['feat!: breaking API change'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('0.3.0'));
    });

    test('applies patch increment for feature commit on 0.x.x versions', () {
      final version = Version.parse('0.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('0.2.4'));
    });

    test('applies patch increment for fix commit on 0.x.x versions', () {
      final version = Version.parse('0.2.3');
      const commits = ['fix: bug fix'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('0.2.4'));
    });

    test('breaking change dominates other commits', () {
      final version = Version.parse('1.2.3');
      const commits = [
        'feat: new feature',
        'fix: bug fix',
        'feat!: breaking change',
      ];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('2.0.0'));
    });

    test('ignores commits not matching the config', () {
      final version = Version.parse('1.2.3');
      const commits = ['build: update dependencies'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(version);
    });

    test('supports custom config to map new commit types', () {
      final version = Version.parse('1.2.3');
      const commits = ['docs: update README'];
      final config = VersioningConfig(
        incrementByCommitType: {'docs': VersionIncrement.patch},
      );
      final nextVersion = version.nextVersion(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });

    test('returns the same version on empty commit list', () {
      final version = Version.parse('1.2.3');
      check(version.nextVersion(const [])).equals(version);
    });

    test('pre-release increment on pre-release version', () {
      final version = Version.parse('1.2.3-alpha.1');
      const commits = ['fix: minor fix'];
      final config = VersioningConfig(
        incrementByCommitType: {'fix': VersionIncrement.preRelease},
      );
      final nextVersion = version.nextVersion(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.3-alpha.2'));
    });

    test('applies highest applicable increment from multiple commits', () {
      final version = Version.parse('1.2.3');
      const commits = [
        'fix: minor bug fix',
        'perf: improve performance',
        'feat: add new feature',
      ];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });
  });

  group('VersionExtension', () {
    test('nextVersion method increments version correctly', () {
      final version = Version.parse('1.2.3');
      const commits = ['feat: add new feature'];
      final nextVersion = version.nextVersion(commits);
      check(nextVersion).equals(Version.parse('1.3.0'));
    });

    test('nextVersion method respects custom config', () {
      final version = Version.parse('1.2.3');
      const commits = ['docs: update documentation'];
      final config = VersioningConfig(
        incrementByCommitType: {'docs': VersionIncrement.patch},
      );
      final nextVersion = version.nextVersion(commits, config: config);
      check(nextVersion).equals(Version.parse('1.2.4'));
    });
  });
}
