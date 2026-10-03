import 'package:erls_dino/components/dino.dart';
import 'package:erls_dino/components/garlic.dart';
import 'package:erls_dino/components/mint_choco.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('garlic hitbox follows the silhouette, not the sprite rectangle', () {
    final hitbox =
        Garlic(position: Vector2.zero()).buildHitboxes().first as PolygonHitbox;

    // Empty space beside the stem must not be collidable.
    expect(hitbox.containsPoint(Vector2(20, 6)), isFalse);
    // The stem and the bulb must be collidable.
    expect(hitbox.containsPoint(Vector2(13, 3)), isTrue);
    expect(hitbox.containsPoint(Vector2(20, 40)), isTrue);
    expect(hitbox.containsPoint(Vector2(13, 40)), isTrue);
  });

  test('mint choco hitbox follows the silhouette', () {
    final hitbox = MintChoco(position: Vector2.zero())
        .buildHitboxes()
        .first as PolygonHitbox;

    // Empty top corner must not be collidable.
    expect(hitbox.containsPoint(Vector2(2, 4)), isFalse);
    // The wide middle and the tapered base must be collidable.
    expect(hitbox.containsPoint(Vector2(9, 12)), isTrue);
    expect(hitbox.containsPoint(Vector2(9, 35)), isTrue);
  });

  test('dino hitbox trims the empty bottom-left leg gap', () {
    final hitbox = Dino.createHitbox() as PolygonHitbox;

    // Empty space beside the legs must not be collidable.
    expect(hitbox.containsPoint(Vector2(15, 47)), isFalse);
    // The body and the right leg must be collidable.
    expect(hitbox.containsPoint(Vector2(24, 30)), isTrue);
    expect(hitbox.containsPoint(Vector2(33, 47)), isTrue);
  });
}
