import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/smol_jump_game.dart';

/// The sun or the moon. Its visibility is driven by the day/night cycle via
/// [setIntensity]; the sprite's colors are preserved while it fades.
class CelestialBody extends SpriteComponent with HasGameReference<SmolJumpGame> {
  CelestialBody({
    required this.asset,
    required super.position,
    required Vector2 size,
    super.priority,
  }) : super(size: size, anchor: Anchor.center);

  final String asset;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load(asset));
    paint.filterQuality = FilterQuality.none;
    setIntensity(1);
  }

  /// [value] in `[0, 1]` fades the body in/out without changing its colors.
  void setIntensity(double value) {
    final a = value.clamp(0.0, 1.0);
    paint.colorFilter = ColorFilter.mode(
      Color.fromRGBO(255, 255, 255, a),
      BlendMode.modulate,
    );
  }
}
