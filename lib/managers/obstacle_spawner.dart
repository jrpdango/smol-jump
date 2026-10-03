import 'dart:math';

import 'package:flame/components.dart';

import '../components/garlic.dart';
import '../components/mint_choco.dart';
import '../game/erls_dino_game.dart';
import '../game/world.dart';

/// Drives weighted obstacle spawning with a distance based gap.
class ObstacleSpawner extends Component with HasGameReference<ErlsDinoGame> {
  static const double spawnX = ErlsDinoWorld.groundRight + 6;
  static const double _garlicWeight = 0.6;
  static const double _minGap = 130;
  static const double _maxExtraGap = 120;
  static const double _minDelay = 0.6;

  final Random _random = Random();
  double _timeUntilSpawn = 0.6;

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isRunning || game.isGameOver) {
      return;
    }
    _timeUntilSpawn -= dt;
    if (_timeUntilSpawn > 0) {
      return;
    }
    _spawn();
  }

  void _spawn() {
    final y = ErlsDinoWorld.groundY;
    final obstacle = _random.nextDouble() < _garlicWeight
        ? Garlic(position: Vector2(spawnX, y))
        : MintChoco(position: Vector2(spawnX, y));
    game.world.add(obstacle);

    final gap = _minGap + _random.nextDouble() * _maxExtraGap;
    _timeUntilSpawn = max(_minDelay, gap / game.world.speed);
  }

  void reset() {
    _timeUntilSpawn = 0.6;
  }
}
