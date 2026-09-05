import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the bundled fonts' licenses with Flutter's license registry.
///
/// Embedding an OFL face in a shipped binary is redistribution, and the OFL
/// requires the license and copyright notice to travel with it. Registering
/// here puts both in `showLicensePage`, which is the app's only licenses
/// surface, alongside the ones Flutter collects from packages automatically.
///
/// Call once from `main`. The registry takes a stream factory and does not read
/// it until something asks for licenses, so this costs nothing at launch.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield await _license('Instrument Sans', 'InstrumentSans-OFL.txt');
    yield await _license('JetBrains Mono', 'JetBrainsMono-OFL.txt');
  });
}

Future<LicenseEntryWithLineBreaks> _license(String family, String file) async {
  final String text = await rootBundle.loadString('assets/fonts/$file');
  return LicenseEntryWithLineBreaks(<String>[family], text);
}
