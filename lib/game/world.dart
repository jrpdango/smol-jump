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

  /// The ground/scene strip is drawn wider than the 180 virtual field so it
  /// still covers the screen when integer zoom leaves visible area outside the
  /// 9:16 field. `virtualWidth * 2` is the upper bound of the visible world
  /// width for any integer zoom >= 1.
  static const double groundWidth = virtualWidth * 2;
  static const double groundLeft = virtualWidth / 2 - groundWidth / 2;
  static const double groundRight = groundLeft + groundWidth;

  /// Fixed horizontal position (bottom-center) of the dino.
  static const double dinoX = 40;

  static const double baseSpeed = 120;
  static const double maxSpeed = 230;

  /// Time to ease from [baseSpeed] to [maxSpeed]. The curve starts and ends
  /// with zero slope so the acceleration never feels abrupt.
  static const double speedRampSeconds = 60;

  /// Eased scroll speed at [elapsed] seconds into a run.
  static double speedAt(double elapsed) {
    final p = (elapsed / speedRampSeconds).clamp(0.0, 1.0);
    final eased = p * p * (3 - 2 * p);
    return baseSpeed + (maxSpeed - baseSpeed) * eased;
  }

  late final Dino dino = Dino();
  late final Ground ground = Ground();
  late final ObstacleSpawner spawner = ObstacleSpawner();

  double speed = baseSpeed;
  double elapsed = 0;

  @override
  Future<void> onLoad() async {
    final random = Random();
    await add(ground);
    for (var i = 0; i < 4; i++) {
      await add(
        Cloud(
          position: Vector2(
            groundLeft + 40 + i * 80.0,
            16 + random.nextDouble() * 70,
          ),
        ),
      );
    }
    await add(dino);
    await add(spawner);
  }

  @override
  void update(double dt) {
    final running = game.isRunning && !game.isGameOver;
    if (running) {
      elapsed += dt;
      speed = speedAt(elapsed);
    } else {
      speed = baseSpeed;
    }
    // Push the speed out before children update so the ground, obstacles and
    // clouds all scroll from the exact same value in a given frame.
    ground.setScrollSpeed(running ? speed : 0);
    super.update(dt);
  }

  void reset() {
    for (final obstacle in children.whereType<Obstacle>().toList()) {
      obstacle.removeFromParent();
    }
    speed = baseSpeed;
    elapsed = 0;
    spawner.reset();
    dino.reset();
    ground.setScrollSpeed(speed);
  }
}
