import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';
import '../game/world.dart';
import 'dino.dart';

/// Shared behaviour for every scrolling obstacle.
abstract class Obstacle extends SpriteComponent
    with HasGameReference<ErlsDinoGame>, CollisionCallbacks {
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
    add(
      RectangleHitbox(
        position: Vector2(size.x * 0.12, 0),
        size: Vector2(size.x * 0.76, size.y * 0.94),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    position.x -= game.world.speed * dt;
    position.x = position.x.roundToDouble();
    if (position.x + size.x < -2) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other.parent is Dino) {
      game.dinoHit();
    }
  }
}
