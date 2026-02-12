import 'dart:convert';
import 'dart:io';

import 'package:next_version/next_version.dart';
import 'package:yaml_edit/yaml_edit.dart';

RegExp _monorepoTagRegex(String package) => RegExp(
  '^${RegExp.escape(package)}-v(\\d+\\.\\d+\\.\\d+(?:[-+][0-9A-Za-z\\.-]+)?)\$',
);
final _singlePackageTagRegex = RegExp(
  r'^v(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z\.-]+)?)$',
);
final _publishToNoneRegex = RegExp(
  r'^\s*publish_to:\s*none\s*$',
  multiLine: true,
);
final _nameRegex = RegExp(r'^\s*name:\s*(.+)$', multiLine: true);
final _versionRegex = RegExp(r'^\s*version:\s*(.+)$', multiLine: true);

void _section(String title, [String emoji = '']) {
  stdout
    ..writeln('\n$emoji $title')
    ..writeln('─' * (title.length + 2));
}

void _field(String label, Object value) {
  stdout.writeln('  ${label.padRight(14)} $value');
}

String _getRepoRoot() {
  final result = Process.runSync('git', ['rev-parse', '--show-toplevel']);
  if (result.exitCode != 0) {
    _exitWithError('❌ Not inside a git repository.');
  }
  return result.stdout.toString().trim();
}

bool _isMonorepo(String repoRoot) {
  final root = Directory(repoRoot);

  final pubspecFile = File('$repoRoot/pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final yaml = YamlEditor(pubspecFile.readAsStringSync());
    final workspaceNode = yaml.parseAt([
      'workspace',
    ], orElse: () => wrapAsYamlNode(null));
    if (workspaceNode.value != null) return true;
  }

  // Structural detection: more than one package in repo
  var packageCount = 0;

  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('pubspec.yaml')) {
      final content = entity.readAsStringSync();

      // Skip private / example packages
      if (_publishToNoneRegex.hasMatch(content)) continue;

      // Must have name + version to be considered a real package
      final hasName = _nameRegex.hasMatch(content);
      final hasVersion = _versionRegex.hasMatch(content);

      if (hasName && hasVersion) {
        packageCount++;
        if (packageCount > 1) return true;
      }
    }
  }

  return false;
}

String _getPackageName(YamlEditor yamlEditor) {
  final node = yamlEditor.parseAt(['name'], orElse: () => wrapAsYamlNode(null));
  if (node.value == null) {
    _exitWithError('❌ "name" field not found in pubspec.yaml.');
  }
  return node.value as String;
}

String _getCurrentVersion(YamlEditor yamlEditor) {
  final node = yamlEditor.parseAt([
    'version',
  ], orElse: () => wrapAsYamlNode(null));
  if (node.value == null) {
    _exitWithError('❌ "version" field not found in pubspec.yaml.');
  }
  return node.value as String;
}

String _getLastGitTag(String package, {required bool isMonorepo}) {
  final result = Process.runSync('git', [
    'tag',
    '--list',
    if (isMonorepo) '$package-v*',
    '--sort=-creatordate',
  ]);

  if (result.exitCode != 0) {
    _exitWithError('❌ Failed to retrieve Git tags.');
  }

  final tags = result.stdout
      .toString()
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  if (tags.isEmpty) {
    _exitWithError('❌ No tags found for package $package.');
  }

  return tags.first;
}

List<String> _getCommitMessagesSince(
  String latestTag,
  String packagePath, {
  required bool isMonorepo,
}) {
  final result = Process.runSync('git', [
    'log',
    '$latestTag..HEAD',
    '--pretty=format:%s',
    if (isMonorepo) ...['--', packagePath],
  ]);

  if (result.exitCode != 0) {
    _exitWithError('❌ Error retrieving commit messages.');
  }

  return LineSplitter.split(
    result.stdout.toString(),
  ).where((e) => e.isNotEmpty).toList();
}

Version _calculateNextVersion(
  String packageName,
  String lastTag,
  List<String> commits, {
  required bool isMonorepo,
}) {
  final match =
      (isMonorepo ? _monorepoTagRegex(packageName) : _singlePackageTagRegex)
          .firstMatch(lastTag);
  if (match == null) {
    _exitWithError('❌ Unsupported tag format: $lastTag');
  }

  final lastVersion = Version.parse(match!.group(1)!);
  final next = lastVersion.nextVersion(commits);

  if (next == lastVersion) {
    _section('Result', '🎯');
    stdout.writeln('  ✅ No version bump required.');
    exit(0);
  }

  return next;
}

void _updatePubspecVersion(File file, YamlEditor yaml, String next) {
  try {
    yaml.update(['version'], next);
    file.writeAsStringSync(yaml.toString());
  } catch (e) {
    _exitWithError('❌ Failed to update pubspec.yaml: $e');
  }
}

void _exitWithError(String message) {
  stderr.writeln(message);
  exit(1);
}

void main(List<String> args) {
  final repoRoot = _getRepoRoot();
  final packagePath = Directory.current.path.replaceFirst(
    '$repoRoot${Platform.pathSeparator}',
    '',
  );
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    _exitWithError('❌ pubspec.yaml not found in current directory.');
  }
  final yaml = YamlEditor(pubspecFile.readAsStringSync());

  final isMonorepo = _isMonorepo(repoRoot);
  final packageName = _getPackageName(yaml);
  final currentVersion = _getCurrentVersion(yaml);
  _section('Repository', '📁');
  _field('Root', repoRoot);
  _field('Package', packageName);
  _field('Path', packagePath);
  _field('Mode', isMonorepo ? 'Monorepo' : 'Single package');

  final lastTag = _getLastGitTag(packageName, isMonorepo: isMonorepo);
  _section('Version Info', '🏷️');
  _field('Current', currentVersion);
  _field('Latest Tag', lastTag);

  final commits = _getCommitMessagesSince(
    lastTag,
    packagePath,
    isMonorepo: isMonorepo,
  );
  if (commits.isEmpty) {
    _section('Result', '🎯');
    stdout.writeln('  ✅ No changes since last release.');
    return;
  }

  _section('Changes Since Last Release', '📝');
  for (final c in commits) {
    stdout.writeln('  • $c');
  }

  final nextVersion = _calculateNextVersion(
    packageName,
    lastTag,
    commits,
    isMonorepo: isMonorepo,
  );
  _section('Result', '🎯');
  _field('Next Version', nextVersion);

  _updatePubspecVersion(pubspecFile, yaml, nextVersion.toString());
  stdout.writeln('\n✅ pubspec.yaml updated successfully.');
}
