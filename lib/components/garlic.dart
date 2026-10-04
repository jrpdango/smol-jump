import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

/// Tall static obstacle.
class Garlic extends Obstacle {
  Garlic({required super.position})
      : super(
          spritePath: 'garlic.png',
          size: Vector2(29, 54),
        );

  /// A forgiving outline of the garlic: a narrow stem/leaf column on top of a
  /// wide bulb. A plain rectangle would cover the empty corners beside the
  /// stem, letting the dino clip invisible space while airborne.
  @override
  Iterable<ShapeHitbox> buildHitboxes() => [
        PolygonHitbox([
          Vector2(11, 2), // top-left of the leaves
          Vector2(18, 2), // top-right of the leaves
          Vector2(18, 30), // stem base, right
          Vector2(21, 32), // bulb shoulder, right
          Vector2(24, 35),
          Vector2(26, 38),
          Vector2(27, 42), // bulb widest, right
          Vector2(25, 46),
          Vector2(22, 49),
          Vector2(19, 51), // bulb taper
          Vector2(18, 52), // bottom edge, right
          Vector2(11, 52), // bottom edge, left
          Vector2(10, 51),
          Vector2(7, 49),
          Vector2(4, 46),
          Vector2(1, 42), // bulb widest, left
          Vector2(2, 38),
          Vector2(4, 35),
          Vector2(7, 32), // bulb shoulder, left
          Vector2(10, 30), // stem base, left
          Vector2(10, 2),
        ]),
      ];
}
