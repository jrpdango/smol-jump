import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/smol_jump_game.dart';
import '../game/world.dart';
import 'tintable.dart';

/// A drifting, wrapping background cloud.
///
/// Each cloud belongs to a parallax layer (defined by [speedMultiplier], its
/// [size] and its vertical band). It loads every variant of its layer and picks
/// one at random whenever it respawns, so a layer never looks repetitive.
class Cloud extends SpriteComponent
    with HasGameReference<SmolJumpGame>, Tintable {
  Cloud({
    required super.position,
    required this.assets,
    required Vector2 size,
    required this.minY,
    required this.maxY,
    this.speedMultiplier = 0.3,
    Random? random,
  })  : _random = random ?? Random(),
        super(size: size, anchor: Anchor.topLeft);

  /// The variant sprites available to this cloud's layer.
  final List<String> assets;
  final double speedMultiplier;

  /// Vertical band (world px) the cloud is allowed to occupy.
  final double minY;
  final double maxY;

  final Random _random;

  late final List<Sprite> _sprites;

  @override
  Future<void> onLoad() async {
    _sprites = [
      for (final asset in assets) Sprite(await game.images.load(asset)),
    ];
    paint.filterQuality = FilterQuality.none;
    _pickVariant();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    position.x -= game.world.speed * speedMultiplier * dt;
    if (position.x + size.x < SmolJumpWorld.groundLeft) {
      respawn();
    }
  }

  /// Move the cloud just off the right edge and randomize its band/variant.
  void respawn() {
    randomizePosition(
      x: SmolJumpWorld.groundRight + _random.nextDouble() * 60,
    );
  }

  /// Scatter the cloud anywhere across the scene, keeping it inside its band.
  void randomizePosition({double? x}) {
    position
      ..x = (x ??
              (SmolJumpWorld.groundLeft +
                  _random.nextDouble() * SmolJumpWorld.groundWidth))
          .roundToDouble()
      ..y = (minY + _random.nextDouble() * (maxY - minY)).roundToDouble();
    _pickVariant();
  }

  void _pickVariant() {
    sprite = _sprites[_random.nextInt(_sprites.length)];
  }
}
