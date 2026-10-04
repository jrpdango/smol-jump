import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

/// Short static obstacle.
class MintChoco extends Obstacle {
  MintChoco({required super.position})
      : super(
          spritePath: 'mint-choco.png',
          size: Vector2(21, 39),
        );

  /// A forgiving outline that follows the rounded middle and tapered top and
  /// bottom instead of a rectangle with empty corners.
  @override
  Iterable<ShapeHitbox> buildHitboxes() => [
        PolygonHitbox([
          Vector2(8, 2), // rounded top
          Vector2(15, 2),
          Vector2(17, 4),
          Vector2(19, 7),
          Vector2(20, 9), // widest section, right
          Vector2(20, 15),
          Vector2(19, 18),
          Vector2(18, 22),
          Vector2(16, 26),
          Vector2(15, 30),
          Vector2(14, 34),
          Vector2(13, 37), // tapered base, right
          Vector2(8, 37),
          Vector2(7, 34),
          Vector2(6, 30),
          Vector2(5, 26),
          Vector2(3, 22),
          Vector2(2, 18),
          Vector2(1, 15),
          Vector2(1, 9), // widest section, left
          Vector2(2, 7),
          Vector2(4, 4),
        ]),
      ];
}
