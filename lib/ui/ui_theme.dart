import 'package:flutter/material.dart';

/// Shared visual language for every Flutter overlay (menu, pause, game over)
/// and the in-game HUD. One font, one button, one set of text treatments so
/// the screens feel like a single game instead of stock Material widgets.
class UiTheme {
  UiTheme._();

  static const String fontFamily = 'Pixel Operator';

  /// Dark translucent scrim used behind modal overlays.
  static const Color scrim = Color(0xCC10121C);

  /// Panel fill behind buttons and cards.
  static const Color panel = Color(0xF0151826);
  static const Color panelBorder = Color(0xFF3A4160);

  static const Color ink = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFB9C0D4);
  static const Color accent = Color(0xFFF2C14E);
  static const Color outline = Color(0xFF10121C);

  /// Four-way dark offset that fakes a pixel outline around glyphs, keeping the
  /// HUD readable over both the bright day and dark night skies.
  static const List<Shadow> textOutline = [
    Shadow(color: outline, offset: Offset(-1.5, 0)),
    Shadow(color: outline, offset: Offset(1.5, 0)),
    Shadow(color: outline, offset: Offset(0, -1.5)),
    Shadow(color: outline, offset: Offset(0, 1.5)),
    Shadow(color: outline, offset: Offset(1, 1)),
    Shadow(color: outline, offset: Offset(-1, 1)),
    Shadow(color: outline, offset: Offset(1, -1)),
    Shadow(color: outline, offset: Offset(-1, -1)),
  ];

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 52,
    letterSpacing: 1,
    color: ink,
    shadows: textOutline,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 38,
    letterSpacing: 1,
    color: ink,
    shadows: textOutline,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    letterSpacing: 1,
    color: ink,
    shadows: textOutline,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: muted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24,
    letterSpacing: 1.5,
    color: ink,
  );

  /// Zero-padded score, matching the in-game HUD.
  static String formatScore(int value) => value.toString().padLeft(5, '0');
}

/// A squared-off, high-contrast button used across all overlays.
class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.label,
    this.onPressed,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Primary (accent) vs. secondary (neutral) treatment.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final background = accent ? UiTheme.accent : UiTheme.panel;
    final foreground = accent ? UiTheme.outline : UiTheme.ink;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledForegroundColor: UiTheme.muted,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(200, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: accent ? UiTheme.accent : UiTheme.panelBorder,
            width: 2,
          ),
        ),
        textStyle: UiTheme.button.copyWith(color: foreground),
      ),
      child: Text(label),
    );
  }
}
