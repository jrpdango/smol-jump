import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Lets the day/night cycle multiply a sprite's colors by a tint.
///
/// `Color(0xFFFFFFFF)` leaves the sprite unchanged; darker/warmer colors shift
/// its mood. Works on any component that mixes in `HasPaint`.
mixin Tintable on HasPaint {
  void applyTint(Color color) {
    paint.colorFilter = ColorFilter.mode(color, BlendMode.modulate);
  }
}
