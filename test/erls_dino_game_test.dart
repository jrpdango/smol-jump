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
    // has to rise above the garlic's hitbox top.
    const garlicHeight = 54.0;
    final discriminant = v0 * v0 - 2 * g * garlicHeight;
    expect(discriminant, greaterThan(0));
    final airborneWindow = 2 * sqrt(discriminant) / g;

    // Horizontal ground covered while clearing must exceed the combined hitbox
    // width (dino 24px + garlic 26 * 0.76).
    const overlap = 24.0 + 26.0 * 0.76;
    final clearance = ErlsDinoWorld.baseSpeed * airborneWindow;
    expect(clearance, greaterThanOrEqualTo(overlap));
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
