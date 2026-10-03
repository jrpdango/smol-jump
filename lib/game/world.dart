import 'dart:math';

import 'package:flame/components.dart';

import '../components/cloud.dart';
import '../components/dino.dart';
import '../components/ground.dart';
import '../components/obstacle.dart';
import '../managers/obstacle_spawner.dart';
import 'erls_dino_game.dart';

/// The fixed virtual play field (180 x 320, 9:16 portrait).
///
/// All gameplay coordinates are expressed in these virtual pixels; the camera
/// applies an integer zoom so every virtual pixel maps to whole screen pixels.
class ErlsDinoWorld extends World
    with HasCollisionDetection, HasGameReference<ErlsDinoGame> {
  static const double virtualWidth = 180;
  static const double virtualHeight = 320;
  static const double groundHeight = 12;

  /// Y coordinate of the top of the ground / bottom of everything standing.
  static const double groundY = virtualHeight - groundHeight;

  /// Fixed horizontal position (bottom-center) of the dino.
  static const double dinoX = 40;

  static const double baseSpeed = 55;
  static const double maxSpeed = 170;
  static const double acceleration = 2.5;

  late final Dino dino = Dino();
  late final Ground ground = Ground();
  late final ObstacleSpawner spawner = ObstacleSpawner();

  double speed = baseSpeed;
  double elapsed = 0;

  @override
  Future<void> onLoad() async {
    final random = Random();
    await add(ground);
    for (var i = 0; i < 3; i++) {
      await add(
        Cloud(position: Vector2(20 + i * 60.0, 18 + random.nextDouble() * 60)),
      );
    }
    await add(dino);
    await add(spawner);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final running = game.isRunning && !game.isGameOver;
    if (running) {
      elapsed += dt;
      speed = min(baseSpeed + acceleration * elapsed, maxSpeed);
    } else {
      speed = baseSpeed;
    }
    ground.setScrollSpeed(running ? speed : 0);
  }

  void reset() {
    for (final obstacle in children.whereType<Obstacle>().toList()) {
      obstacle.removeFromParent();
    }
    speed = baseSpeed;
    elapsed = 0;
    spawner.reset();
    dino.startRunning();
    ground.setScrollSpeed(speed);
  }
}
