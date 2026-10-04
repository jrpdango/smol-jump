import 'package:smol_jump/game/smol_jump_game.dart';
import 'package:smol_jump/ui/overlays.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SmolJumpGame> pumpGame(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final game = SmolJumpGame();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        GameWidget<SmolJumpGame>(
          game: game,
          overlayBuilderMap: buildOverlayBuilderMap(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    return game;
  }

  testWidgets('starts with a full stock of hearts', (tester) async {
    final game = await pumpGame(tester);

    expect(game.lives, SmolJumpGame.maxLives);
    expect(game.isInvincible, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('a hit costs a heart but does not end the run', (tester) async {
    final game = await pumpGame(tester);
    game.phase = GamePhase.playing;

    game.dinoHit();

    expect(game.lives, SmolJumpGame.maxLives - 1);
    expect(game.isInvincible, isTrue);
    expect(game.phase, GamePhase.playing);
    expect(game.isGameOver, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('hits during the grace window are ignored', (tester) async {
    final game = await pumpGame(tester);
    game.phase = GamePhase.playing;

    game.dinoHit();
    game.dinoHit();
    game.dinoHit();

    expect(game.lives, SmolJumpGame.maxLives - 1);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('damage resumes once the grace window expires', (tester) async {
    final game = await pumpGame(tester);
    game.phase = GamePhase.playing;

    game.dinoHit();
    game.update(SmolJumpGame.invincibleSeconds + 0.01);

    expect(game.isInvincible, isFalse);

    game.dinoHit();
    expect(game.lives, SmolJumpGame.maxLives - 2);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('losing the last heart ends the run', (tester) async {
    final game = await pumpGame(tester);
    game.phase = GamePhase.playing;

    for (var i = 0; i < SmolJumpGame.maxLives; i++) {
      game.dinoHit();
      game.update(SmolJumpGame.invincibleSeconds + 0.01);
    }

    expect(game.lives, 0);
    expect(game.phase, GamePhase.gameOver);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('restarting refills the hearts', (tester) async {
    final game = await pumpGame(tester);
    game.phase = GamePhase.playing;
    game.lives = 1;
    game.dinoHit();

    game.restartGame();

    expect(game.lives, SmolJumpGame.maxLives);
    expect(game.isInvincible, isFalse);
    expect(game.phase, GamePhase.playing);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));
}
