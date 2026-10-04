import 'dart:math';

import 'package:flame/components.dart';

import '../components/dino.dart';
import '../components/durian.dart';
import '../components/garlic.dart';
import '../components/mint_choco.dart';
import '../game/smol_jump_game.dart';
import '../game/world.dart';

/// The two kinds of hazard the spawner mixes. Ground hazards are always jumped.
/// Aerial durians vary in height: low ones skim the dino and must be jumped,
/// tall ones sit above the jump and must be run under.
enum HazardType { ground, aerial }

/// Drives weighted obstacle spawning with a distance based gap.
class ObstacleSpawner extends Component with HasGameReference<SmolJumpGame> {
  static const double spawnX = SmolJumpWorld.groundRight + 6;
  static const double _garlicWeight = 0.6;
  static const double _aerialWeight = 0.35;
  static const double _minGap = 130;
  static const double _maxExtraGap = 120;

  /// Human reaction budget applied when the next hazard demands a different
  /// action than the last one.
  static const double reactionSeconds = 0.25;

  /// Floor on the time between obstacles. Must exceed the dino's air time so it
  /// can land and jump again; the extra margin covers touch reaction time. Only
  /// bites at high speed, where the distance-based gap would otherwise be too
  /// short to jump in succession.
  static final double minGapSeconds = Dino.jumpAirTime + 0.20;

  /// Shortest time between two hazards that can follow each other, by type.
  ///
  /// Any transition involving an aerial waits out a full jump (plus reaction):
  /// a low durian must be jumped, so the player has to be back on the ground
  /// before they can read the next hazard. Otherwise they simply need enough
  /// time to react and launch a jump.
  static double floorSecondsFor(HazardType from, HazardType to) =>
      switch ((from, to)) {
        (HazardType.ground, HazardType.ground) => minGapSeconds,
        (HazardType.ground, HazardType.aerial) => _afterAirTime,
        (HazardType.aerial, HazardType.ground) => minGapSeconds,
        (HazardType.aerial, HazardType.aerial) => _afterAirTime,
      };

  static final double _afterAirTime = Dino.jumpAirTime + reactionSeconds;

  /// Delay before the next hazard, combining the distance-based gap with the
  /// per-transition floor. [randomFraction] is in [0, 1).
  static double gapSeconds({
    required double speed,
    required HazardType from,
    required HazardType to,
    required double randomFraction,
  }) {
    final distance = _minGap + randomFraction * _maxExtraGap;
    return max(floorSecondsFor(from, to), distance / speed);
  }

  final Random _random = Random();
  double _timeUntilSpawn = minGapSeconds;
  HazardType _lastType = HazardType.ground;
  bool _first = true;

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

  HazardType _pickType() {
    if (_first) {
      return HazardType.ground;
    }
    return _random.nextDouble() < _aerialWeight
        ? HazardType.aerial
        : HazardType.ground;
  }

  void _spawn() {
    final type = _pickType();
    final groundY = SmolJumpWorld.groundY;
    final obstacle = switch (type) {
      HazardType.ground => _random.nextDouble() < _garlicWeight
          ? Garlic(position: Vector2(spawnX, groundY))
          : MintChoco(position: Vector2(spawnX, groundY)),
      HazardType.aerial => Durian(
          position: Vector2(spawnX, groundY),
          bottomClearance: Durian.minBottomClearance +
              _random.nextDouble() *
                  (Durian.maxBottomClearance - Durian.minBottomClearance),
        ),
    };
    game.world.add(obstacle);

    _timeUntilSpawn = gapSeconds(
      speed: game.world.speed,
      from: _lastType,
      to: type,
      randomFraction: _random.nextDouble(),
    );
    _lastType = type;
    _first = false;
  }

  void reset() {
    _timeUntilSpawn = minGapSeconds;
    _lastType = HazardType.ground;
    _first = true;
  }
}
