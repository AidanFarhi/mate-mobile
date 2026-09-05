import 'package:flutter/material.dart';
import 'package:mate/app/theme/app_palette.dart';
import 'package:mate/app/theme/app_spacing.dart';
import 'package:mate/app/theme/app_typography.dart';
import 'package:mate/app/theme/board_palette.dart';
import 'package:mate/core/error/app_failure.dart';
import 'package:mate/ui/components/app_button.dart';
import 'package:mate/ui/components/app_empty_state.dart';
import 'package:mate/ui/components/app_error_state.dart';
import 'package:mate/ui/components/app_loading.dart';
import 'package:mate/ui/components/app_profile_icon.dart';
import 'package:mate/ui/components/app_result_chip.dart';
import 'package:mate/ui/components/app_screen_header.dart';
import 'package:mate/ui/components/app_tab_bar.dart';
import 'package:mate/ui/components/app_toast.dart';

/// Every token and shared component on one scrollable page.
///
/// Debug builds only -- the route is not registered in release (see
/// `app_router.dart`). It exists for two jobs: seeing the design system whole
/// while building against it, and checking layouts at 200% text without owning
/// a device set to it. The scale control at the top is the second job; the
/// widget test in `test/ui/gallery/` drives the same page at 2.0 and fails on
/// an overflow, so a component that cannot take the scaling breaks CI rather
/// than waiting for someone to open this screen.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const List<double> _scales = <double>[1.0, 1.3, 1.5, 2.0];
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenInset,
              ),
              child: _ScaleControl(
                scales: _scales,
                selected: _scale,
                onChanged: (double value) => setState(() => _scale = value),
              ),
            ),
            Divider(color: palette.divider, height: 1),
            Expanded(
              // Only the specimens are scaled, not the control above them --
              // otherwise raising the scale can push the way back down off the
              // screen.
              child: MediaQuery.withClampedTextScaling(
                minScaleFactor: _scale,
                maxScaleFactor: _scale,
                child: const _GalleryBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleControl extends StatelessWidget {
  const _ScaleControl({
    required this.scales,
    required this.selected,
    required this.onChanged,
  });

  final List<double> scales;
  final double selected;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: AppScreenHeader(
            title: 'Gallery',
            backLabel: 'Back',
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
        Wrap(
          spacing: AppSpacing.x6,
          children: <Widget>[
            for (final double scale in scales)
              GestureDetector(
                onTap: () => onChanged(scale),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x8,
                    vertical: AppSpacing.x6,
                  ),
                  decoration: BoxDecoration(
                    color: scale == selected
                        ? palette.accentWash
                        : palette.fillSoft,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                  ),
                  child: Text(
                    '${(scale * 100).round()}%',
                    style: type.metaSmall.copyWith(
                      color: scale == selected
                          ? palette.accent
                          : palette.textTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);
    final BoardPalette board = BoardPalette.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenInset,
        AppSpacing.x18,
        AppSpacing.screenInset,
        AppSpacing.x26,
      ),
      children: <Widget>[
        _Section(
          label: 'Buttons',
          children: <Widget>[
            for (final AppButtonVariant variant in AppButtonVariant.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x10),
                child: AppButton(
                  label: variant.name,
                  onPressed: () =>
                      AppToast.show(context, '${variant.name} tap'),
                  variant: variant,
                ),
              ),
            const AppButton(label: 'disabled', onPressed: null),
            const SizedBox(height: AppSpacing.x10),
            Row(
              children: <Widget>[
                AppButton(
                  label: 'medium',
                  onPressed: () {},
                  size: AppButtonSize.medium,
                  variant: AppButtonVariant.secondary,
                  expand: false,
                ),
                const SizedBox(width: AppSpacing.x10),
                AppButton(
                  label: 'Add',
                  onPressed: () {},
                  size: AppButtonSize.small,
                  expand: false,
                ),
              ],
            ),
          ],
        ),
        _Section(
          label: 'Result chips',
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.x10,
              runSpacing: AppSpacing.x10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (final ResultChipKind kind in ResultChipKind.values) ...[
                  AppResultChip(kind: kind),
                  Text(
                    kind.name,
                    style: type.metaSmall.copyWith(color: palette.textTertiary),
                  ),
                ],
              ],
            ),
          ],
        ),
        _Section(
          label: 'Profile icons',
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.x10,
              runSpacing: AppSpacing.x10,
              children: <Widget>[
                for (int id = 0; id < AppProfileIcons.count; id++)
                  AppProfileIcon(iconId: id),
              ],
            ),
            const SizedBox(height: AppSpacing.x12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AppProfileIcon(iconId: 0, size: 26),
                SizedBox(width: AppSpacing.x10),
                AppProfileIcon(iconId: 0, size: 36),
                SizedBox(width: AppSpacing.x10),
                AppProfileIcon(iconId: 0, size: 62),
                SizedBox(width: AppSpacing.x10),
                AppProfileIcon(iconId: 0, size: 62, inverted: true),
              ],
            ),
          ],
        ),
        _Section(
          label: 'Empty state',
          children: <Widget>[
            const AppEmptyState(
              title: 'No active game',
              message: 'Challenge a friend below. One game at a time.',
            ),
            const SizedBox(height: AppSpacing.x12),
            AppEmptyState(
              title: 'No friends yet',
              message: 'Add someone by username or friend code.',
              actionLabel: 'Add a friend',
              onAction: () => AppToast.show(context, 'Add a friend'),
            ),
          ],
        ),
        _Section(
          label: 'Error states',
          children: <Widget>[
            AppErrorState(
              failure: const NetworkFailure(),
              onRetry: () => AppToast.show(context, 'retry'),
            ),
            Divider(color: palette.divider),
            // Not retryable: the retry button must not appear even though a
            // callback was supplied.
            AppErrorState(
              failure: const UnauthorizedFailure(),
              onRetry: () => AppToast.show(context, 'retry'),
            ),
          ],
        ),
        const _Section(
          label: 'Loading',
          children: <Widget>[
            Row(
              children: <Widget>[
                AppLoadingIndicator(),
                SizedBox(width: AppSpacing.x14),
                AppLoadingIndicator(size: 28),
              ],
            ),
            SizedBox(height: AppSpacing.x12),
            SizedBox(
              height: 120,
              child: AppLoadingScreen(label: 'Reconnecting…'),
            ),
          ],
        ),
        _Section(
          label: 'Toasts',
          children: <Widget>[
            AppButton(
              label: 'Plain toast',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.medium,
              onPressed: () =>
                  AppToast.show(context, 'mira.k is now a friend.'),
            ),
            const SizedBox(height: AppSpacing.x10),
            AppButton(
              label: 'Failure toast',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.medium,
              onPressed: () => AppToast.showFailure(
                context,
                const ConflictFailure(
                  message: 'You already have an active game. Finish it first.',
                ),
              ),
            ),
          ],
        ),
        _Section(
          label: 'Tab bar',
          children: <Widget>[
            AppTabBar(
              items: const <AppTabItem>[
                AppTabItem(label: 'Play', route: '/'),
                AppTabItem(label: 'Friends', route: '/friends'),
                AppTabItem(label: 'You', route: '/you'),
              ],
              selectedIndex: 0,
              onSelected: (int index) => AppToast.show(context, 'tab $index'),
            ),
          ],
        ),
        _Section(
          label: 'Typography',
          children: <Widget>[
            for (final (String name, TextStyle style) in <(String, TextStyle)>[
              ('wordmark', type.wordmark),
              ('screenTitle', type.screenTitle),
              ('sectionTitle', type.sectionTitle),
              ('statValue', type.statValue),
              ('body', type.body),
              ('rowPrimary', type.rowPrimary),
              ('rowPrimaryCompact', type.rowPrimaryCompact),
              ('rowSecondary', type.rowSecondary),
              ('button', type.button),
              ('buttonSmall', type.buttonSmall),
              ('tabLabel', type.tabLabel),
              ('label', type.label),
              ('labelWide', type.labelWide),
              ('meta', type.meta),
              ('metaSmall', type.metaSmall),
              ('notation', type.notation),
              ('code', type.code),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.x8),
                child: Text(
                  name,
                  style: style.copyWith(color: palette.textPrimary),
                ),
              ),
          ],
        ),
        _Section(
          label: 'Palette',
          children: <Widget>[
            _Swatches(
              entries: <(String, Color)>[
                ('ground', palette.ground),
                ('surface', palette.surface),
                ('surfaceSubtle', palette.surfaceSubtle),
                ('surfaceRaised', palette.surfaceRaised),
                ('surfaceToast', palette.surfaceToast),
                ('fill', palette.fill),
                ('fillSoft', palette.fillSoft),
                ('avatarFill', palette.avatarFill),
                ('track', palette.track),
                ('hairline', palette.hairline),
                ('divider', palette.divider),
                ('border', palette.border),
                ('textPrimary', palette.textPrimary),
                ('textSecondary', palette.textSecondary),
                ('textTertiary', palette.textTertiary),
                ('textQuaternary', palette.textQuaternary),
                ('accent', palette.accent),
                ('accentWashSoft', palette.accentWashSoft),
                ('accentWash', palette.accentWash),
                ('accentWashStrong', palette.accentWashStrong),
                ('accentBorder', palette.accentBorder),
                ('danger', palette.danger),
                ('dangerWash', palette.dangerWash),
                ('onAccent', palette.onAccent),
                ('onDanger', palette.onDanger),
                ('scrimSheet', palette.scrimSheet),
                ('scrimModal', palette.scrimModal),
              ],
            ),
          ],
        ),
        _Section(
          label: 'Board palette',
          children: <Widget>[
            _Swatches(
              entries: <(String, Color)>[
                ('lightSquare', board.lightSquare),
                ('darkSquare', board.darkSquare),
                ('lightSquareActive', board.lightSquareActive),
                ('darkSquareActive', board.darkSquareActive),
                ('selection', board.selection),
                ('captureRing', board.captureRing),
                ('moveDot', board.moveDot),
                ('pieceBlack', board.pieceBlack),
                ('pieceWhite', board.pieceWhite),
                ('pieceWhiteOutline', board.pieceWhiteOutline),
                ('pieceShadow', board.pieceShadow),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSectionLabel(label),
          const SizedBox(height: AppSpacing.x12),
          ...children,
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.entries});

  final List<(String, Color)> entries;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(context);
    final AppTypography type = AppTypography.of(context);

    return Wrap(
      spacing: AppSpacing.x10,
      runSpacing: AppSpacing.x10,
      children: <Widget>[
        for (final (String name, Color color) in entries)
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    // Translucent tokens are invisible against `ground` without
                    // an edge to read them by.
                    border: Border.all(color: palette.hairline),
                  ),
                ),
                const SizedBox(height: AppSpacing.x3),
                Text(
                  name,
                  style: type.metaSmall.copyWith(color: palette.textTertiary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
