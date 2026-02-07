[![Package: halildurmus_hooks][package_badge]][package_link]
[![Publisher: halildurmus.dev][publisher_badge]][publisher_link]
[![Language: Dart][language_badge]][language_link]
[![License: BSD-3-Clause][license_badge]][license_link]

**A collection of scripts for Git hooks.**

Use these small Dart CLIs to keep your repo healthy before commits or pushes.

## Included scripts

- `analyze` - Runs `dart analyze` (or `flutter analyze` with `-f`).
- `format` - Checks formatting with `dart format --set-exit-if-changed`.
- `test` - Runs `dart test` (or `flutter test` with `-f`).
- `check_commit` - Validates a commit message against Conventional Commits.
- `bump_version` - Calculates the next version from commit messages and
  updates `pubspec.yaml`.
- `update_changelog` - Uses `git-cliff` to update `CHANGELOG.md`.

## Usage

Here's an example [Lefthook](https://lefthook.dev/) configuration that uses
these scripts:

```yaml
pre-commit:
  parallel: true
  commands:
    analyze:
      glob: '*.{dart}'
      run: dart run hooks:analyze example lib test
    format:
      glob: '*.{dart}'
      run: dart run hooks:format {staged_files}
    test:
      glob: '{lib,test}/**/*.dart'
      run: dart run hooks:test -- -j 1 --test-randomize-ordering-seed=random

commit-msg:
  commands:
    check_commit:
      run: dart run hooks:check_commit {1}
```

## Notes

- `analyze` and `test` scripts accept `-f` / `--flutter` to run via Flutter.
- `bump_version` script expects the latest Git tag to match `vX.Y.Z` or
 `package_name-vX.Y.Z`.
- `update_changelog` script requires `git-cliff` to be installed and available
  on `PATH`.

[language_badge]: https://img.shields.io/badge/language-Dart-blue.svg
[language_link]: https://dart.dev
[license_badge]: https://img.shields.io/github/license/halildurmus/tools?color=blue
[license_link]: https://opensource.org/licenses/BSD-3-Clause
[package_badge]: https://img.shields.io/pub/v/halildurmus_hooks.svg
[package_link]: https://pub.dev/packages/halildurmus_hooks
[publisher_badge]: https://img.shields.io/pub/publisher/halildurmus_hooks.svg
[publisher_link]: https://pub.dev/publishers/halildurmus.dev
