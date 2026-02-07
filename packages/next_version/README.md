[![Package: next_version][package_badge]][package_link]
[![Publisher: halildurmus.dev][publisher_badge]][publisher_link]
[![Language: Dart][language_badge]][language_link]
[![License: BSD-3-Clause][license_badge]][license_link]

**A Dart package for calculating the next semantic version based on conventional
commits.**

`package:next_version` analyzes commit messages that follow the
[Conventional Commits](https://www.conventionalcommits.org/) specification and
determines the appropriate semantic version increment automatically.

It is designed for tooling, CI pipelines, and release automation.

## Usage

Compute the next version from a list of commit messages:

```dart
import 'package:next_version/next_version.dart';

void main() {
  final currentVersion = Version.parse('1.2.3');
  const commits = ['feat: add a new feature', 'fix: resolve an issue'];
  final nextVersion = currentVersion.nextVersion(commits);
  print('🚀 Next version: $nextVersion'); // 1.3.0
}
```

[language_badge]: https://img.shields.io/badge/language-Dart-blue.svg
[language_link]: https://dart.dev
[license_badge]: https://img.shields.io/github/license/halildurmus/tools?color=blue
[license_link]: https://opensource.org/licenses/BSD-3-Clause
[package_badge]: https://img.shields.io/pub/v/next_version.svg
[package_link]: https://pub.dev/packages/next_version
[publisher_badge]: https://img.shields.io/pub/publisher/next_version.svg
[publisher_link]: https://pub.dev/publishers/halildurmus.dev
