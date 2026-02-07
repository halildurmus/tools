An example project that wires `package:halildurmus_hooks` into Lefthook.

## Setup

1. Add the package as a dev dependency (see `pubspec.yaml`).
2. Copy `lefthook.yml` to your repo root.
3. Run `lefthook install`.

## What it runs

- `analyze` on staged Dart files.
- `format` on staged Dart files.
- `test` for `lib/` and `test/`.
- `check_commit` on commit messages.
