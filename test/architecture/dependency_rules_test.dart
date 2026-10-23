import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Enforce dependency direction as part of the normal CI test run.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  final directives = RegExp(r"(?:import|export)\s+'([^']+)'");

  List<String> violations(
    bool Function(String path) matches,
    bool Function(String target) forbidden,
  ) {
    final result = <String>[];
    for (final file in files.where((file) => matches(file.path))) {
      for (final match in directives.allMatches(file.readAsStringSync())) {
        final uri = match[1]!;
        final target = uri.startsWith('package:rick_and_morty_catalog/')
            ? 'lib/${uri.substring('package:rick_and_morty_catalog/'.length)}'
            : uri.startsWith('package:') || uri.startsWith('dart:')
            ? uri
            : file.uri.resolve(uri).path;
        if (forbidden(target)) result.add('${file.path} -> $uri');
      }
    }
    return result;
  }

  bool framework(String target) =>
      target.startsWith('package:flutter') || target.startsWith('package:dio/');

  test(
    'domain depends only on Dart, domain and framework-free core contracts',
    () {
      expect(
        violations(
          (path) => path.contains('/domain/'),
          (target) =>
              framework(target) ||
              target.contains('/data/') ||
              target.contains('/presentation/') ||
              target.contains('/app/') ||
              target.contains('/core/network/') ||
              target.contains('/core/theme/'),
        ),
        isEmpty,
      );
    },
  );

  test('presentation cannot access data implementations or Dio', () {
    expect(
      violations(
        (path) => path.contains('/presentation/'),
        (target) =>
            target.contains('/data/') ||
            target.startsWith('package:dio/') ||
            target.contains('/core/network/') ||
            target.contains('/app/'),
      ),
      isEmpty,
    );
  });

  test('data cannot depend on presentation or app composition', () {
    expect(
      violations(
        (path) => path.contains('/data/'),
        (target) =>
            target.contains('/presentation/') ||
            target.contains('/app/') ||
            target.startsWith('package:flutter'),
      ),
      isEmpty,
    );
  });

  test('core has no feature or application dependencies', () {
    expect(
      violations(
        (path) => path.startsWith('lib/core/'),
        (target) => target.contains('/features/') || target.contains('/app/'),
      ),
      isEmpty,
    );
  });
}
