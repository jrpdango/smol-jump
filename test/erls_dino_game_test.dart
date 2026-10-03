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
