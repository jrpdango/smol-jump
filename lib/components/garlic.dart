import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

/// Tall static obstacle.
class Garlic extends Obstacle {
  Garlic({required super.position})
      : super(
          spritePath: 'garlic.png',
          size: Vector2(26, 54),
        );

  /// A forgiving outline of the garlic: a narrow stem/leaf column on top of a
  /// wide bulb. A plain rectangle would cover the empty corners beside the
  /// stem, letting the dino clip invisible space while airborne.
  @override
  Iterable<ShapeHitbox> buildHitboxes() => [
        PolygonHitbox([
          Vector2(9, 2), // top-left of the leaves
          Vector2(16, 2), // top-right of the leaves
          Vector2(14, 6), // slim down into the stem
          Vector2(14, 30), // stem base, right
          Vector2(20, 32), // bulb shoulder, right
          Vector2(24, 36),
          Vector2(25, 44),
          Vector2(23, 48), // bulb taper
          Vector2(18, 52),
          Vector2(9, 52), // bottom edge
          Vector2(5, 48),
          Vector2(2, 44), // bulb taper, left
          Vector2(2, 36),
          Vector2(6, 32), // bulb shoulder, left
          Vector2(10, 30), // stem base, left
          Vector2(10, 6),
        ]),
      ];
}
