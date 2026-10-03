import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';
import '../game/world.dart';

/// A parallax cloud that drifts left slower than the ground and wraps around.
class Cloud extends SpriteComponent with HasGameReference<ErlsDinoGame> {
  Cloud({required super.position, this.speedMultiplier = 0.3})
      : super(size: Vector2(46, 14), anchor: Anchor.topLeft);

  final double speedMultiplier;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load('cloud.png'));
    paint.filterQuality = FilterQuality.none;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= game.world.speed * speedMultiplier * dt;
    position.x = position.x.roundToDouble();
    if (position.x + size.x < ErlsDinoWorld.groundLeft) {
      position
        ..x = (ErlsDinoWorld.groundRight + _random.nextDouble() * 40)
            .roundToDouble()
        ..y = (16 + _random.nextDouble() * 70).roundToDouble();
    }
  }
}
