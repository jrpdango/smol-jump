import 'dart:math';

import 'package:smol_jump/components/dino.dart';
import 'package:smol_jump/components/durian.dart';
import 'package:smol_jump/game/smol_jump_game.dart';
import 'package:smol_jump/game/world.dart';
import 'package:smol_jump/managers/obstacle_spawner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('game starts idle with a zero score', () {
    final game = SmolJumpGame();
    expect(game.score, 0);
    expect(game.highScore, 0);
    expect(game.isRunning, isFalse);
    expect(game.isGameOver, isFalse);
  });

  test('virtual layout places the ground above the bottom edge', () {
    expect(SmolJumpWorld.virtualWidth, 180);
    expect(SmolJumpWorld.virtualHeight, 320);
    expect(SmolJumpWorld.groundY, 308);
  });

  test('base speed can clear the tall garlic from the start', () {
    const v0 = -Dino.jumpVelocity;
    const g = Dino.gravity;

    // Tallest obstacle (garlic, 54px) must be cleared: the dino's hitbox bottom
    // has to rise above the garlic's topmost hitbox vertex. Both hitboxes are
    // polygons inset from their sprites, so only the gap must be cleared.
    const garlicHitboxTop = 54.0 - 2.0;
    const dinoHitboxBottom = 52.0 - 48.0;
    final discriminant =
        v0 * v0 - 2 * g * (garlicHitboxTop - dinoHitboxBottom);
    expect(discriminant, greaterThan(0));
    final airborneWindow = 2 * sqrt(discriminant) / g;

    // Horizontal ground covered while clearing must exceed the combined hitbox
    // width (dino 20px wide + garlic 26px wide at its widest).
    const overlap = 20.0 + 26.0;
    final clearance = SmolJumpWorld.baseSpeed * airborneWindow;
    expect(clearance, greaterThanOrEqualTo(overlap));
  });

  group('obstacle spacing', () {
    test('dino can land and jump again between consecutive obstacles', () {
      expect(Dino.jumpAirTime, closeTo(0.6667, 0.001));

      // The spawner's time floor must exceed a full jump's air time, otherwise
      // the dino is still airborne when the next obstacle arrives at high speed.
      expect(ObstacleSpawner.minGapSeconds, greaterThan(Dino.jumpAirTime));
      expect(ObstacleSpawner.minGapSeconds, closeTo(0.8667, 0.001));
    });
  });

  group('speed ramp', () {
    test('stays within base and max speed', () {
      for (var t = 0.0; t <= SmolJumpWorld.speedRampSeconds * 2; t += 5) {
        final speed = SmolJumpWorld.speedAt(t);
        expect(speed, greaterThanOrEqualTo(SmolJumpWorld.baseSpeed));
        expect(speed, lessThanOrEqualTo(SmolJumpWorld.maxSpeed));
      }
    });

    test('eases in gently, ramps monotonically, then caps out', () {
      expect(SmolJumpWorld.speedAt(0), SmolJumpWorld.baseSpeed);
      expect(
        SmolJumpWorld.speedAt(SmolJumpWorld.speedRampSeconds),
        SmolJumpWorld.maxSpeed,
      );
      expect(
        SmolJumpWorld.speedAt(SmolJumpWorld.speedRampSeconds * 3),
        SmolJumpWorld.maxSpeed,
      );

      // The first second adds less speed than a second at the ramp midpoint,
      // proving the curve starts with a gentle slope.
      final startGain = SmolJumpWorld.speedAt(1) - SmolJumpWorld.speedAt(0);
      final mid = SmolJumpWorld.speedRampSeconds / 2;
      final midGain = SmolJumpWorld.speedAt(mid + 1) - SmolJumpWorld.speedAt(mid);
      expect(startGain, lessThan(midGain));

      var previous = SmolJumpWorld.speedAt(0);
      for (var t = 1.0; t <= SmolJumpWorld.speedRampSeconds; t += 1) {
        final speed = SmolJumpWorld.speedAt(t);
        expect(speed, greaterThanOrEqualTo(previous));
        previous = speed;
      }
    });
  });

  group('zoomForWidth', () {
    test('uses whole-number zoom and never drops below 1', () {
      expect(SmolJumpGame.zoomForWidth(180), 1);
      expect(SmolJumpGame.zoomForWidth(359), 1);
      expect(SmolJumpGame.zoomForWidth(360), 2);
      expect(SmolJumpGame.zoomForWidth(540), 3);
      expect(SmolJumpGame.zoomForWidth(720), 4);
    });
  });

  group('aerial hazard', () {
    const dinoHitboxTop = 52.0 - 16.0; // 36px above ground
    const dinoHitboxBottom = 52.0 - 48.0; // 4px above ground
    final jumpPeak =
        Dino.jumpVelocity * Dino.jumpVelocity / (2 * Dino.gravity);
    final highestReach = dinoHitboxBottom + jumpPeak;

    double hitboxBottom(double clearance) =>
        clearance + Durian.hitboxBottomInset;
    double hitboxTop(double clearance) => clearance + Durian.hitboxTopInset;

    test('spans forced jumps, apex clears and un-jumpable heights', () {
      final lowestBottom = hitboxBottom(Durian.minBottomClearance);
      final lowestTop = hitboxTop(Durian.minBottomClearance);
      final highestBottom = hitboxBottom(Durian.maxBottomClearance);
      final highestTop = hitboxTop(Durian.maxBottomClearance);

      // The lowest durian overlaps a grounded dino, so it must be jumped...
      expect(lowestBottom, lessThan(dinoHitboxTop));
      // ...and it clears comfortably within the jump.
      expect(lowestTop, lessThan(highestReach));

      // The highest durian is safe to run under...
      expect(highestBottom, greaterThan(dinoHitboxTop));
      // ...but its top is above the dino's reach, so it cannot be jumped.
      expect(highestTop, greaterThan(highestReach));
    });

    test('every height is either jumpable or safe to run under', () {
      for (var clearance = Durian.minBottomClearance;
          clearance <= Durian.maxBottomClearance;
          clearance += 1) {
        final canJumpOver = hitboxTop(clearance) < highestReach;
        final canRunUnder = hitboxBottom(clearance) > dinoHitboxTop;
        expect(
          canJumpOver || canRunUnder,
          isTrue,
          reason: 'clearance $clearance is impossible to avoid',
        );
      }
    });
  });

  group('hazard sequencing', () {
    test('ground to aerial waits out a full jump', () {
      expect(
        ObstacleSpawner.floorSecondsFor(HazardType.ground, HazardType.aerial),
        greaterThan(Dino.jumpAirTime),
      );
    });

    test('aerial to aerial waits out a full jump', () {
      expect(
        ObstacleSpawner.floorSecondsFor(HazardType.aerial, HazardType.aerial),
        greaterThan(Dino.jumpAirTime),
      );
    });

    test('aerial to ground leaves room to jump', () {
      expect(
        ObstacleSpawner.floorSecondsFor(HazardType.aerial, HazardType.ground),
        greaterThanOrEqualTo(ObstacleSpawner.minGapSeconds),
      );
    });

    test('distance gap never drops below the transition floor', () {
      final floor = ObstacleSpawner.floorSecondsFor(
        HazardType.ground,
        HazardType.aerial,
      );
      for (var speed = SmolJumpWorld.baseSpeed;
          speed <= SmolJumpWorld.maxSpeed;
          speed += 60) {
        for (final fraction in [0.0, 0.5, 0.99]) {
          final delay = ObstacleSpawner.gapSeconds(
            speed: speed,
            from: HazardType.ground,
            to: HazardType.aerial,
            randomFraction: fraction,
          );
          expect(delay, greaterThanOrEqualTo(floor));
        }
      }
    });
  });
}
