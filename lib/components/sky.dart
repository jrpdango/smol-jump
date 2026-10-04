import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/world.dart';

/// Static vertical-gradient sky drawn behind everything else.
///
/// The camera never translates (only its zoom changes), so a world-space
/// rectangle stays anchored to the screen. It is sized generously to cover the
/// extra area revealed when integer zoom leaves gaps around the 9:16 field.
class Sky extends RectangleComponent {
  Sky()
      : super(
          position: Vector2(
            SmolJumpWorld.groundLeft,
            -SmolJumpWorld.virtualHeight,
          ),
          size: Vector2(
            SmolJumpWorld.groundWidth,
            SmolJumpWorld.virtualHeight * 2,
          ),
          priority: -10,
        );

  /// Fallback daytime palette, used until the cycle applies its own.
  static const Color dayTop = Color(0xFF56A9D4);
  static const Color dayMid = Color(0xFF9BD3EC);
  static const Color dayHorizon = Color(0xFFF7E4B8);

  int? _lastTop;
  int? _lastMid;
  int? _lastHorizon;

  @override
  Future<void> onLoad() async {
    applyPalette(top: dayTop, mid: dayMid, horizon: dayHorizon);
  }

  /// Rebuilds the gradient from three colors, skipping the work when nothing
  /// changed (the cycle interpolates continuously, so this matters).
  ///
  /// The rectangle spans `-virtualHeight .. virtualHeight`, so the visible
  /// field (y `0 .. groundY`) maps to the upper-middle of the stops; anything
  /// above y=0 is clamped to [top].
  void applyPalette({
    required Color top,
    required Color mid,
    required Color horizon,
  }) {
    final t = top.toARGB32();
    final m = mid.toARGB32();
    final h = horizon.toARGB32();
    if (t == _lastTop && m == _lastMid && h == _lastHorizon) {
      return;
    }
    _lastTop = t;
    _lastMid = m;
    _lastHorizon = h;
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top, mid, horizon],
      stops: const [0.5, 0.74, 0.98],
    ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
  }
}
