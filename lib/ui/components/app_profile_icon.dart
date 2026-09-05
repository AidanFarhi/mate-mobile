import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';

/// The fixed set of profile icons.
///
/// Eight of them, chosen once at Profile Setup (#7) and immutable after. The
/// wire format is the *index* -- `User.icon` is an int, matching the prototype
/// -- so the glyph table below can be replaced without migrating any data.
///
/// The glyphs are placeholders. `docs/design/ui_design.md` lists the icon set
/// under "Assets / to be produced for V1" and calls the prototype's Unicode
/// characters stand-ins for a set of designed icons that does not exist yet.
/// Rather than invent artwork nobody approved, this keeps the stand-ins behind
/// the id indirection: when the real set arrives, [AppProfileIcons.glyphs]
/// becomes an asset table and no call site changes.
class AppProfileIcons {
  const AppProfileIcons._();

  /// Placeholder artwork, indexed by icon id. Order is part of the contract --
  /// existing accounts are stored as an index into this list.
  static const List<String> glyphs = <String>[
    '♞', // knight
    '♜', // rook
    '♝', // bishop
    '♛', // queen
    '♚', // king
    '♟', // pawn
    '◆', // diamond
    '●', // disc
  ];

  static int get count => glyphs.length;

  /// Whether [id] names an icon in the current set.
  static bool isValid(int id) => id >= 0 && id < glyphs.length;

  /// The glyph for [id], falling back to the first icon.
  ///
  /// A server that has grown its icon set before the client has must not crash
  /// the friends list, so an unknown id degrades to a real avatar instead of
  /// throwing. The assert still catches it in debug, where it is our bug.
  static String glyphFor(int id) {
    assert(isValid(id), 'Unknown profile icon id: $id');
    return isValid(id) ? glyphs[id] : glyphs.first;
  }
}

/// One profile icon in its circle, sized for the row it sits in.
///
/// [inverted] is the signed-in user's own avatar: bone-white ground with ink
/// glyph, against everyone else's translucent ground with a bone glyph. That
/// inversion is how the design distinguishes you from your opponent on the
/// board without a label.
class AppProfileIcon extends StatelessWidget {
  const AppProfileIcon({
    required this.iconId,
    this.size = 34,
    this.inverted = false,
    super.key,
  });

  final int iconId;

  /// Diameter. The design uses 26 (active-game card), 34 (list rows),
  /// 36 (player strips) and 62 (profile headers).
  final double size;

  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: inverted ? palette.textPrimary : palette.avatarFill,
      ),
      child: Text(
        AppProfileIcons.glyphFor(iconId),
        // Not scaled by the system text setting: this is artwork standing in
        // for an image, and growing it would burst its own circle.
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: size * 0.52,
          height: 1,
          color: inverted ? palette.onAccent : palette.textPrimary,
        ),
      ),
    );
  }
}
