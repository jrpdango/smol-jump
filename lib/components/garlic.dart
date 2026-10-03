import 'package:flame/components.dart';

import 'obstacle.dart';

/// Tall static obstacle.
class Garlic extends Obstacle {
  Garlic({required super.position})
      : super(
          spritePath: 'garlic.png',
          size: Vector2(26, 54),
        );
}
