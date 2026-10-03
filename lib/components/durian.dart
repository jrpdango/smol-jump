import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'obstacle.dart';

/// Aerial hazard whose height varies. Low durians skim the dino's body, so
/// they must be jumped. Tall durians sit above even a full jump's reach, so
/// they must be run under. In between are durians that just clear at the apex.
/// The mix exists to punish mindless jump-spamming: the player has to read each
/// hazard instead of tapping on a beat.
///
/// The temporary art is a spiky green orb; its collision band is defined by
/// [minBottomClearance] / [maxBottomClearance] and the hitbox insets below, not
/// by the sprite silhouette.
class Durian extends Obstacle {
  Durian({required super.position, required double bottomClearance})
      : super(
          spritePath: 'durian.png',
          size: Vector2(spriteSizeX, spriteSizeY),
          groundOffset: bottomClearance,
        );

  static const double spriteSizeX = 24;
  static const double spriteSizeY = 24;

  /// Range (above the ground) the sprite's bottom is floated to. The low end
  /// overlaps a grounded dino (must jump); the high end is above the dino's
  /// maximum reach (must run under).
  static const double minBottomClearance = 12;
  static const double maxBottomClearance = 84;

  /// Hitbox insets from the sprite's bottom edge, matching the octagon below.
  static const double hitboxBottomInset = 4;
  static const double hitboxTopInset = 20;

  /// Lowest and highest world-space heights the hitbox can occupy. Kept public
  /// so tests can prove every height in the range is either jumpable or safe to
  /// run under, never both impossible and unavoidable.
  static double get minHitboxBottom => minBottomClearance + hitboxBottomInset;
  static double get maxHitboxBottom => maxBottomClearance + hitboxBottomInset;
  static double get minHitboxTop => minBottomClearance + hitboxTopInset;
  static double get maxHitboxTop => maxBottomClearance + hitboxTopInset;

  /// Octagon that hugs the spiky orb. Centered at (12, 12) with radius 8.
  @override
  Iterable<ShapeHitbox> buildHitboxes() => [
        PolygonHitbox([
          Vector2(20, 12),
          Vector2(18, 18),
          Vector2(12, 20),
          Vector2(6, 18),
          Vector2(4, 12),
          Vector2(6, 6),
          Vector2(12, 4),
          Vector2(18, 6),
        ]),
      ];
}
