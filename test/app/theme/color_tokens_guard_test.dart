import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Anything that names a color without going through the theme.
final RegExp _rawColor = RegExp(
  r'Color\(0x|Color\.fromRGBO\(|Color\.fromARGB\(|Colors\.(?!transparent\b)',
);

/// The only directory allowed to spell a color out.
const String _tokenDir = 'lib/app/theme/';

void main() {
  test('color literals exist only in the theme', () {
    // #3's acceptance criterion is that nothing outside the design system
    // defines its own colors. A review can miss one hex; this cannot. When a
    // screen needs a shade that is not here, the fix is a token, not a literal
    // -- that is what keeps one dark theme from drifting into several.
    //
    // `Colors.transparent` is exempt: it is the absence of a color, not a
    // choice of one.
    final List<String> offenders = <String>[];

    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.startsWith(_tokenDir)) {
        continue;
      }

      final List<String> lines = entity.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        if (_rawColor.hasMatch(lines[i])) {
          offenders.add('${entity.path}:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'move these into AppPalette or BoardPalette',
    );
  });

  test('the guard is looking at real files', () {
    // A path typo would make the test above pass by scanning nothing.
    final int dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .length;
    expect(dartFiles, greaterThan(10));
    expect(File('${_tokenDir}app_palette.dart').existsSync(), isTrue);
  });
}
