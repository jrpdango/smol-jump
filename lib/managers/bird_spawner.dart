import 'dart:math';

import 'package:flame/components.dart';

import '../components/bird.dart';
import '../game/erls_dino_game.dart';
import '../game/world.dart';

/// Spawns decorative flocks of [Bird]s at random intervals. Birds are added
/// directly to the world (not as children) so their render priority places them
/// behind the clouds.
class BirdSpawner extends Component with HasGameReference<ErlsDinoGame> {
  BirdSpawner({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const double minInterval = 3.5;
  static const double maxInterval = 9.0;
  static const double minY = 55;
  static const double maxY = 145;
  static const double spawnX = ErlsDinoWorld.groundRight + 20;

  double _timer = 0;
  double _next = 0;

  @override
  void onMount() {
    super.onMount();
    _scheduleNext();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    _timer += dt;
    if (_timer >= _next) {
      _timer = 0;
      _scheduleNext();
      _spawnFlock();
    }
  }

  void reset() {
    _timer = 0;
    _scheduleNext();
  }

  void _scheduleNext() {
    _next = minInterval + _random.nextDouble() * (maxInterval - minInterval);
  }

  void _spawnFlock() {
    final count = 1 + _random.nextInt(3);
    final baseY = minY + _random.nextDouble() * (maxY - minY);
    final speed = 0.5 + _random.nextDouble() * 0.2;
    for (var i = 0; i < count; i++) {
      game.world.add(
        Bird(
          speedMultiplier: speed,
          position: Vector2(
            (spawnX + i * (14 + _random.nextDouble() * 10)).roundToDouble(),
            (baseY + (_random.nextDouble() - 0.5) * 12).roundToDouble(),
          ),
        ),
      );
    }
  }
}
