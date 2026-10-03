import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Adds a moonlight rim around a sprite that fades in as night falls.
///
/// The host exposes its current frame via [outlineSprite]. The rim is drawn as
/// solid silhouette copies offset by one virtual pixel in the eight cardinal
/// and diagonal directions, so it stays on the pixel grid and never softens the
/// art. It is drawn under the sprite's own render, so the sprite stays on top.
mixin NightOutline on PositionComponent, HasPaint {
  /// Muted warm moonlight that reads as a soft edge rather than a bright UI
  /// outline.
  static const Color defaultOutlineColor = Color(0xFFDCC894);

  /// Peak rim opacity at full night. Kept well below 1 so the rim blends into
  /// the dark sky instead of popping as a hard outline.
  static const double maxOpacity = 0.4;

  /// The sprite to silhouette. Usually the component's current animation frame.
  Sprite? get outlineSprite;

  Color outlineColor = defaultOutlineColor;

  double _outlineIntensity = 0;
  double get outlineIntensity => _outlineIntensity;

  final Paint _outlinePaint = Paint()..filterQuality = FilterQuality.none;

  static final List<Vector2> _offsets = [
    Vector2(-1, -1),
    Vector2(0, -1),
    Vector2(1, -1),
    Vector2(-1, 0),
    Vector2(1, 0),
    Vector2(-1, 1),
    Vector2(0, 1),
    Vector2(1, 1),
  ];

  /// Rim opacity for a cycle's night intensity. Squared so the rim stays subtle
  /// through dusk and dawn and only ramps up once night deepens, then capped at
  /// [maxOpacity] so even full night stays understated.
  static double opacityForNight(double nightIntensity) {
    final n = nightIntensity.clamp(0.0, 1.0);
    return n * n * maxOpacity;
  }

  /// [value] in `[0, 1]`; `0` hides the rim entirely.
  void setOutlineIntensity(double value) {
    _outlineIntensity = value.clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    final sprite = outlineSprite;
    if (_outlineIntensity > 0 && sprite != null) {
      _outlinePaint.colorFilter = ColorFilter.mode(
        outlineColor.withValues(alpha: _outlineIntensity),
        BlendMode.srcIn,
      );
      for (final offset in _offsets) {
        sprite.render(
          canvas,
          position: offset,
          size: size,
          anchor: Anchor.topLeft,
          overridePaint: _outlinePaint,
        );
      }
    }
    super.render(canvas);
  }
}
