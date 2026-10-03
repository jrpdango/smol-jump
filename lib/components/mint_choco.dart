import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

/// Short static obstacle.
class MintChoco extends Obstacle {
  MintChoco({required super.position})
      : super(
          spritePath: 'mint-choco.png',
          size: Vector2(18, 38),
        );

  /// A forgiving outline that follows the rounded middle and tapered top and
  /// bottom instead of a rectangle with empty corners.
  @override
  Iterable<ShapeHitbox> buildHitboxes() => [
        PolygonHitbox([
          Vector2(9, 1), // rounded top
          Vector2(13, 1),
          Vector2(15, 4),
          Vector2(17, 8), // widest section, right
          Vector2(17, 17),
          Vector2(16, 21),
          Vector2(14, 26),
          Vector2(12, 30),
          Vector2(11, 37), // tapered base, right
          Vector2(8, 37),
          Vector2(7, 30),
          Vector2(5, 26),
          Vector2(3, 21),
          Vector2(1, 17), // widest section, left
          Vector2(1, 8),
          Vector2(3, 4),
        ]),
      ];
}
