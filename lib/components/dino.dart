import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/smol_jump_game.dart';
import '../game/world.dart';
import 'night_outline.dart';
import 'tintable.dart';

enum DinoState { idle, run, jump, dead }

/// The player character. Owns a small state machine (idle/run/jump/dead) and
/// the jump physics. Its hitbox is intentionally smaller than the sprite for
/// fair collisions.
class Dino extends SpriteAnimationComponent
    with HasGameReference<SmolJumpGame>, Tintable, NightOutline {
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
  late final List<SpriteAnimation> _deadAnimations;
  late SpriteAnimation _deadAnimation;

  final Random _random = Random();

  @override
  Sprite? get outlineSprite => animationTicker?.getSprite();

  DinoState state = DinoState.idle;
  double _verticalVelocity = 0;

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;

    final idle = await game.images.load('erls-idle.png');
    final run1 = await game.images.load('erls-run-01.png');
    final run2 = await game.images.load('erls-run-02.png');
    final jump = await game.images.load('erls-jump.png');
    final dead1 = await game.images.load('erls-dead-type1.png');
    final dead2 = await game.images.load('erls-dead-type2.png');
    final dead3 = await game.images.load('erls-dead-type3.png');

    _idleAnimation = SpriteAnimation.spriteList([Sprite(idle)], stepTime: 1);
    _runAnimation = SpriteAnimation.spriteList(
      [Sprite(run1), Sprite(run2)],
      stepTime: 0.1,
    );
    _jumpAnimation = SpriteAnimation.spriteList([Sprite(jump)], stepTime: 1);
    _deadAnimations = [
      SpriteAnimation.spriteList([Sprite(dead1)], stepTime: 1),
      SpriteAnimation.spriteList([Sprite(dead2)], stepTime: 1),
      SpriteAnimation.spriteList([Sprite(dead3)], stepTime: 1),
    ];
    _deadAnimation = _deadAnimations.first;

    animation = _idleAnimation;
    position = Vector2(SmolJumpWorld.dinoX, SmolJumpWorld.groundY);

    add(createHitbox());
  }

  void startRunning() {
    if (state == DinoState.dead) {
      return;
    }
    state = DinoState.run;
    _verticalVelocity = 0;
    position.y = SmolJumpWorld.groundY;
    _applyAnimation();
  }

  void jump() {
    if (state != DinoState.run) {
      return;
    }
    state = DinoState.jump;
    _verticalVelocity = jumpVelocity;
    _applyAnimation();
    game.audio.playJump();
  }

  void die() {
    state = DinoState.dead;
    _verticalVelocity = 0;
    _deadAnimation = _pickDeadAnimation();
    _applyAnimation();
  }

  /// Weighted death art: types 1 and 2 at 45% each, type 3 at 10%.
  SpriteAnimation _pickDeadAnimation() {
    final roll = _random.nextDouble();
    if (roll < 0.45) {
      return _deadAnimations[0];
    }
    if (roll < 0.90) {
      return _deadAnimations[1];
    }
    return _deadAnimations[2];
  }

  void reset() {
    _verticalVelocity = 0;
    position.setValues(SmolJumpWorld.dinoX, SmolJumpWorld.groundY);
    state = DinoState.run;
    _applyAnimation();
  }

  /// Returns the dino to its grounded idle pose, used by the main menu.
  void resetToIdle() {
    _verticalVelocity = 0;
    position.setValues(SmolJumpWorld.dinoX, SmolJumpWorld.groundY);
    state = DinoState.idle;
    _applyAnimation();
  }

  void _applyAnimation() {
    switch (state) {
      case DinoState.idle:
        animation = _idleAnimation;
      case DinoState.dead:
        animation = _deadAnimation;
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
      if (position.y >= SmolJumpWorld.groundY) {
        position.y = SmolJumpWorld.groundY;
        _verticalVelocity = 0;
        state = DinoState.run;
        _applyAnimation();
        game.audio.playLand();
      }
    }

    position
      ..x = SmolJumpWorld.dinoX
      ..y = position.y.roundToDouble();
  }
}
