import 'package:next_version/next_version.dart';

void main() {
  final currentVersion = Version.parse('1.2.3');
  const commits = ['feat: add a new feature', 'fix: resolve an issue'];
  final nextVersion = currentVersion.nextVersion(commits);
  print('🚀 Next version: $nextVersion');
}
