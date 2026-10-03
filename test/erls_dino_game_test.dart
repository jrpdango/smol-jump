import 'dart:math';

import 'package:erls_dino/components/dino.dart';
import 'package:erls_dino/game/erls_dino_game.dart';
import 'package:erls_dino/game/world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('game starts idle with a zero score', () {
    final game = ErlsDinoGame();
    expect(game.score, 0);
    expect(game.highScore, 0);
    expect(game.isRunning, isFalse);
    expect(game.isGameOver, isFalse);
  });

  test('virtual layout places the ground above the bottom edge', () {
    expect(ErlsDinoWorld.virtualWidth, 180);
    expect(ErlsDinoWorld.virtualHeight, 320);
    expect(ErlsDinoWorld.groundY, 308);
  });

  test('base speed can clear the tall garlic from the start', () {
    const v0 = -Dino.jumpVelocity;
    const g = Dino.gravity;

    // Tallest obstacle (garlic, 54px) must be cleared: the dino's hitbox bottom
    // has to rise above the garlic's hitbox top. Both hitboxes are inset from
    // their sprites, so only the gap between them must be cleared.
    const garlicHitboxTop = 54.0 * (1 - 0.08 - 0.80);
    const dinoHitboxBottom = 52.0 - (16 + 32);
    final discriminant =
        v0 * v0 - 2 * g * (garlicHitboxTop - dinoHitboxBottom);
    expect(discriminant, greaterThan(0));
    final airborneWindow = 2 * sqrt(discriminant) / g;

    // Horizontal ground covered while clearing must exceed the combined hitbox
    // width (dino 20px + garlic 26 * 0.60).
    const overlap = 20.0 + 26.0 * 0.60;
    final clearance = ErlsDinoWorld.baseSpeed * airborneWindow;
    expect(clearance, greaterThanOrEqualTo(overlap));
  });

  group('speed ramp', () {
    test('stays within base and max speed', () {
      for (var t = 0.0; t <= ErlsDinoWorld.speedRampSeconds * 2; t += 5) {
        final speed = ErlsDinoWorld.speedAt(t);
        expect(speed, greaterThanOrEqualTo(ErlsDinoWorld.baseSpeed));
        expect(speed, lessThanOrEqualTo(ErlsDinoWorld.maxSpeed));
      }
    });

    test('eases in gently, ramps monotonically, then caps out', () {
      expect(ErlsDinoWorld.speedAt(0), ErlsDinoWorld.baseSpeed);
      expect(
        ErlsDinoWorld.speedAt(ErlsDinoWorld.speedRampSeconds),
        ErlsDinoWorld.maxSpeed,
      );
      expect(
        ErlsDinoWorld.speedAt(ErlsDinoWorld.speedRampSeconds * 3),
        ErlsDinoWorld.maxSpeed,
      );

      // The first second adds less speed than a second at the ramp midpoint,
      // proving the curve starts with a gentle slope.
      final startGain = ErlsDinoWorld.speedAt(1) - ErlsDinoWorld.speedAt(0);
      final mid = ErlsDinoWorld.speedRampSeconds / 2;
      final midGain = ErlsDinoWorld.speedAt(mid + 1) - ErlsDinoWorld.speedAt(mid);
      expect(startGain, lessThan(midGain));

      var previous = ErlsDinoWorld.speedAt(0);
      for (var t = 1.0; t <= ErlsDinoWorld.speedRampSeconds; t += 1) {
        final speed = ErlsDinoWorld.speedAt(t);
        expect(speed, greaterThanOrEqualTo(previous));
        previous = speed;
      }
    });
  });

  group('zoomForWidth', () {
    test('uses whole-number zoom and never drops below 1', () {
      expect(ErlsDinoGame.zoomForWidth(180), 1);
      expect(ErlsDinoGame.zoomForWidth(359), 1);
      expect(ErlsDinoGame.zoomForWidth(360), 2);
      expect(ErlsDinoGame.zoomForWidth(540), 3);
      expect(ErlsDinoGame.zoomForWidth(720), 4);
    });
  });
}
