import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';
import '../game/world.dart';
import 'tintable.dart';

/// A decorative bird that flaps across the sky. It has no hitbox and never
/// interacts with gameplay; it despawns once it leaves the scene.
class Bird extends SpriteAnimationComponent
    with HasGameReference<ErlsDinoGame>, Tintable {
  Bird({
    required super.position,
    this.speedMultiplier = 0.55,
    super.priority = -7,
  }) : super(size: Vector2(11, 7), anchor: Anchor.center);

  /// Fraction of the ground speed at which the bird drifts left.
  final double speedMultiplier;

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    final up = await game.images.load('bird-01.png');
    final down = await game.images.load('bird-02.png');
    animation = SpriteAnimation.spriteList(
      [Sprite(up), Sprite(down)],
      stepTime: 0.18,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    position.x -= game.world.speed * speedMultiplier * dt;
    if (position.x < ErlsDinoWorld.groundLeft - size.x) {
      removeFromParent();
    }
  }
}
