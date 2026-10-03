import 'package:flame/components.dart';

import 'obstacle.dart';

/// Short static obstacle.
class MintChoco extends Obstacle {
  MintChoco({required super.position})
      : super(
          spritePath: 'mint-choco.png',
          size: Vector2(18, 38),
        );
}
