import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';

/// How a finished game turned out, from the viewing player's side.
///
/// Four states, not three. [unfinished] is a game that was ended without a
/// result under the stalled-game rule (#27): it appears in history and changes
/// nobody's record. It is deliberately not a draw -- a draw is an outcome, this
/// is the absence of one -- so it gets the only unfilled chip in the set.
///
/// Local to the design system on purpose. #4 owns `Game.status` and the
/// nullable `Game.result`; this is the view of those two fields, and mapping
/// between them belongs to whichever screen holds a `Game`.
enum ResultChipKind { win, loss, draw, unfinished }

/// The square result chip used in every history and match list.
class AppResultChip extends StatelessWidget {
  const AppResultChip({required this.kind, super.key});

  final ResultChipKind kind;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    final (String glyph, String semanticLabel) = switch (kind) {
      ResultChipKind.win => ('W', 'Win'),
      ResultChipKind.loss => ('L', 'Loss'),
      ResultChipKind.draw => ('D', 'Draw'),
      ResultChipKind.unfinished => ('–', 'Unfinished'),
    };

    final (Color background, Color foreground) = switch (kind) {
      ResultChipKind.win => (palette.accentWashStrong, palette.accent),
      ResultChipKind.loss => (palette.dangerWash, palette.danger),
      ResultChipKind.draw => (palette.avatarFill, palette.textSecondary),
      ResultChipKind.unfinished => (Colors.transparent, palette.textTertiary),
    };

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x6,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          // Only the unfinished chip is outlined. With no fill to carry the
          // meaning, the border is what keeps it from reading as empty space.
          border: kind == ResultChipKind.unfinished
              ? Border.all(color: palette.border)
              : null,
        ),
        // A shrink-wrapping Center, not `Container.alignment`: a Container with
        // an alignment expands to fill whatever it is given, which in a Wrap or
        // a Row is the entire width. The chip has to hug its one letter.
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(glyph, style: type.label.copyWith(color: foreground)),
        ),
      ),
    );
  }
}
