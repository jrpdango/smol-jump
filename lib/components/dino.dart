import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';
import '../game/world.dart';
import 'tintable.dart';

enum DinoState { idle, run, jump, dead }

/// The player character. Owns a small state machine (idle/run/jump/dead) and
/// the jump physics. Its hitbox is intentionally smaller than the sprite for
/// fair collisions.
class Dino extends SpriteAnimationComponent
    with HasGameReference<ErlsDinoGame>, Tintable {
  Dino()
      : super(
          size: Vector2(48, 52),
          anchor: Anchor.bottomCenter,
        );

  static const double gravity = 1500;
  static const double jumpVelocity = -500;

  /// Total time the dino spends airborne during a full jump.
  static double get jumpAirTime => 2 * jumpVelocity.abs() / gravity;

  /// The dino's collision shape, in sprite-local pixels. The bottom-left
  /// corner is trimmed so the empty gap between the legs cannot be hit.
  static ShapeHitbox createHitbox() => PolygonHitbox([
        Vector2(14, 16), // upper body, left
        Vector2(34, 16), // upper body, right
        Vector2(34, 48), // bottom of the right leg
        Vector2(18, 48), // trimmed corner
        Vector2(18, 43),
        Vector2(14, 43),
      ]);

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _jumpAnimation;

  DinoState state = DinoState.idle;
  double _verticalVelocity = 0;

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;

    final idle = await game.images.load('erls-idle.png');
    final run1 = await game.images.load('erls-run-01.png');
    final run2 = await game.images.load('erls-run-02.png');
    final jump = await game.images.load('erls-jump.png');

    _idleAnimation = SpriteAnimation.spriteList([Sprite(idle)], stepTime: 1);
    _runAnimation = SpriteAnimation.spriteList(
      [Sprite(run1), Sprite(run2)],
      stepTime: 0.1,
    );
    _jumpAnimation = SpriteAnimation.spriteList([Sprite(jump)], stepTime: 1);

    animation = _idleAnimation;
    position = Vector2(ErlsDinoWorld.dinoX, ErlsDinoWorld.groundY);

    add(createHitbox());
  }

  void startRunning() {
    if (state == DinoState.dead) {
      return;
    }
    state = DinoState.run;
    _verticalVelocity = 0;
    position.y = ErlsDinoWorld.groundY;
    _applyAnimation();
  }

  void jump() {
    if (state != DinoState.run) {
      return;
    }
    state = DinoState.jump;
    _verticalVelocity = jumpVelocity;
    _applyAnimation();
  }

  void die() {
    state = DinoState.dead;
    _verticalVelocity = 0;
    animation = _idleAnimation;
  }

  void reset() {
    _verticalVelocity = 0;
    position.setValues(ErlsDinoWorld.dinoX, ErlsDinoWorld.groundY);
    state = DinoState.run;
    _applyAnimation();
  }

  void _applyAnimation() {
    switch (state) {
      case DinoState.idle:
      case DinoState.dead:
        animation = _idleAnimation;
      case DinoState.run:
        animation = _runAnimation;
      case DinoState.jump:
        animation = _jumpAnimation;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == DinoState.jump) {
      _verticalVelocity += gravity * dt;
      position.y += _verticalVelocity * dt;
      if (position.y >= ErlsDinoWorld.groundY) {
        position.y = ErlsDinoWorld.groundY;
        _verticalVelocity = 0;
        state = DinoState.run;
        _applyAnimation();
      }
    }

    position
      ..x = ErlsDinoWorld.dinoX
      ..y = position.y.roundToDouble();
  }
}
