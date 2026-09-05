import 'package:flutter/material.dart';

/// Board and piece colors.
///
/// Separate from [AppPalette] because these are the only colors in the app that
/// are not part of the chrome: they belong to one widget family (#14, #15) and
/// nothing else should reach for them. V1 ships one fixed board style, so like
/// the rest of the theme there is exactly one instance.
///
/// Board *metrics* -- ring widths, dot size, piece inset -- are not here. They
/// are geometry rather than theme and land with the board widget in #14.
@immutable
class BoardPalette extends ThemeExtension<BoardPalette> {
  const BoardPalette({
    required this.lightSquare,
    required this.darkSquare,
    required this.lightSquareActive,
    required this.darkSquareActive,
    required this.selection,
    required this.captureRing,
    required this.moveDot,
    required this.pieceBlack,
    required this.pieceWhite,
    required this.pieceWhiteOutline,
    required this.pieceShadow,
  });

  /// `board-light`.
  final Color lightSquare;

  /// `board-dark`.
  final Color darkSquare;

  /// `board-light-active` -- a light square in the last move.
  final Color lightSquareActive;

  /// `board-dark-active` -- a dark square in the last move.
  final Color darkSquareActive;

  /// Inset ring on the selected piece's square.
  final Color selection;

  /// Inset ring on a legal destination that holds an enemy piece.
  final Color captureRing;

  /// Centered dot on a legal, empty destination.
  final Color moveDot;

  /// `piece-black`.
  final Color pieceBlack;

  /// `piece-white`.
  final Color pieceWhite;

  /// Thin outline that keeps a white piece legible on a light square.
  final Color pieceWhiteOutline;

  /// The only drop shadow in the design. Everything else is flat.
  final Color pieceShadow;

  /// The app's only board style.
  static const BoardPalette standard = BoardPalette(
    lightSquare: Color(0xFFD9DED0),
    darkSquare: Color(0xFF6E7F63),
    lightSquareActive: Color(0xFFCFDABB),
    darkSquareActive: Color(0xFF68805B),
    selection: Color(0xFFB4C4A8),
    captureRing: Color.fromRGBO(27, 34, 28, 0.45),
    moveDot: Color.fromRGBO(27, 34, 28, 0.3),
    pieceBlack: Color(0xFF1B221C),
    pieceWhite: Color(0xFFF9FAF5),
    pieceWhiteOutline: Color.fromRGBO(27, 34, 28, 0.6),
    pieceShadow: Color.fromRGBO(27, 34, 28, 0.35),
  );

  /// The board palette for [context]. See [AppPalette.of] on why this asserts.
  static BoardPalette of(BuildContext context) {
    final BoardPalette? palette = Theme.of(context).extension<BoardPalette>();
    assert(
      palette != null,
      'BoardPalette missing -- theme is not AppTheme.dark.',
    );
    return palette ?? standard;
  }

  // See AppPalette: one fixed theme, so neither method ever runs.
  @override
  BoardPalette copyWith() => this;

  @override
  BoardPalette lerp(ThemeExtension<BoardPalette>? other, double t) =>
      other is BoardPalette && t >= 0.5 ? other : this;
}
