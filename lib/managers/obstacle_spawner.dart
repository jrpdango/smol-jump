import 'dart:math';

import 'package:flame/components.dart';

import '../components/dino.dart';
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

  /// Floor on the time between obstacles. Must exceed the dino's air time so it
  /// can land and jump again; the extra margin covers touch reaction time. Only
  /// bites at high speed, where the distance-based gap would otherwise be too
  /// short to jump in succession.
  static final double minGapSeconds = Dino.jumpAirTime + 0.20;

  final Random _random = Random();
  double _timeUntilSpawn = minGapSeconds;

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
    _timeUntilSpawn = max(minGapSeconds, gap / game.world.speed);
  }

  void reset() {
    _timeUntilSpawn = minGapSeconds;
  }
}
