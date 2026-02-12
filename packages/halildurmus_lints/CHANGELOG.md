# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-02-12

### 🚀 Features

- [**breaking**] Enable `simplify_variable_pattern` rule by @halildurmus

[2.0.0]: https://github.com/halildurmus/tools/compare/halildurmus_lints-v1.1.0..halildurmus_lints-v2.0.0

## [1.1.0] - 2026-02-06

### 🚀 Features

- Enable new rules by @halildurmus in [#2](https://github.com/halildurmus/tools/pull/2):
  - `remove_deprecations_in_breaking_versions`
  - `switch_on_type`
  - `unnecessary_ignore`
  - `unnecessary_unawaited`

### ⚙️ Miscellaneous Tasks

- Remove `use_if_null_to_convert_nulls_to_bools` rule by @halildurmus in [#3](https://github.com/halildurmus/tools/pull/3)

[1.1.0]: https://github.com/halildurmus/tools/releases/tag/halildurmus_lints-v1.1.0

## 1.0.1 - 2025-05-24

### 🐛 Bug Fixes

- Removed the `unnecessary_unawaited` lint rule from `dart.yaml` as it is not
  supported in Dart v3.8.

## 1.0.0

- Initial version.
