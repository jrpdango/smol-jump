import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';
import '../game/world.dart';
import 'dino.dart';
import 'tintable.dart';

/// Shared behaviour for every scrolling obstacle.
abstract class Obstacle extends SpriteComponent
    with HasGameReference<ErlsDinoGame>, CollisionCallbacks, Tintable {
  Obstacle({
    required this.spritePath,
    required Vector2 size,
    required super.position,
  }) : super(
          size: size,
          anchor: Anchor.bottomLeft,
        );

  final String spritePath;

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    sprite = Sprite(await game.images.load(spritePath));
    position.y = ErlsDinoWorld.groundY;
    for (final hitbox in buildHitboxes()) {
      add(hitbox);
    }
  }

  /// The collision shape(s) for this obstacle, in sprite-local pixels.
  ///
  /// Override to follow the sprite silhouette instead of settling for a
  /// rectangle that also covers transparent corners.
  Iterable<ShapeHitbox> buildHitboxes() => [
        RectangleHitbox(
          position: Vector2(size.x * 0.20, size.y * 0.08),
          size: Vector2(size.x * 0.60, size.y * 0.80),
        ),
      ];

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    position.x -= game.world.speed * dt;
    if (position.x + size.x < ErlsDinoWorld.groundLeft) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Dino) {
      game.dinoHit();
    }
  }
}
