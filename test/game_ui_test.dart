import 'package:erls_dino/components/dino.dart';
import 'package:erls_dino/game/erls_dino_game.dart';
import 'package:erls_dino/ui/overlays.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ErlsDinoGame> pumpGame(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final game = ErlsDinoGame();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        GameWidget<ErlsDinoGame>(
          game: game,
          overlayBuilderMap: buildOverlayBuilderMap(),
          initialActiveOverlays: const [ErlsDinoGame.overlayMainMenu],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    return game;
  }

  testWidgets('launches into the main menu and Play shows the start prompt',
      (tester) async {
    final game = await pumpGame(tester);

    expect(game.phase, GamePhase.menu);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('TAP TO START'), findsNothing);

    await tester.tap(find.text('PLAY'));
    await tester.pump();

    expect(game.phase, GamePhase.ready);
    expect(find.text('PLAY'), findsNothing);
    expect(find.text('TAP TO START'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('tapping the start prompt begins the run and jumps',
      (tester) async {
    final game = await pumpGame(tester);
    game.startGame();
    await tester.pump();

    await tester.tapAt(
      tester.getCenter(find.byType(GameWidget<ErlsDinoGame>)),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(game.phase, GamePhase.playing);
    expect(game.world.dino.state, isNot(DinoState.idle));
    expect(find.text('TAP TO START'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('beginRun launches the dino into a jump', (tester) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();

    expect(game.phase, GamePhase.playing);
    expect(game.world.dino.state, DinoState.jump);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('pause and resume swap overlays and phase', (tester) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    await tester.pump();

    expect(game.phase, GamePhase.playing);

    game.pauseGame();
    await tester.pump();

    expect(game.phase, GamePhase.paused);
    expect(game.isRunning, isFalse);
    expect(find.text('PAUSED'), findsOneWidget);

    game.resumeGame();
    await tester.pump();

    expect(game.phase, GamePhase.playing);
    expect(find.text('PAUSED'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('death shows game over and Play Again restarts immediately',
      (tester) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    await tester.pump();

    game.dinoHit();
    await tester.pump();

    expect(game.phase, GamePhase.gameOver);
    expect(game.isGameOver, isTrue);
    expect(find.text('GAME OVER'), findsOneWidget);
    expect(find.text('PLAY AGAIN'), findsOneWidget);

    await tester.tap(find.text('PLAY AGAIN'));
    await tester.pump();

    expect(game.phase, GamePhase.playing);
    expect(game.isGameOver, isFalse);
    expect(find.text('GAME OVER'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('main menu from game over resets to an idle dino',
      (tester) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    game.dinoHit();
    await tester.pump();

    game.goToMenu();
    await tester.pump();

    expect(game.phase, GamePhase.menu);
    expect(game.world.dino.state, DinoState.idle);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('GAME OVER'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));
}
