import 'package:smol_jump/components/dino.dart';
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
          initialActiveOverlays: const [SmolJumpGame.overlayMainMenu],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    return game;
  }

  testWidgets('launches into the main menu and Play shows the start prompt', (
    tester,
  ) async {
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

  testWidgets('tapping the start prompt begins the run and jumps', (
    tester,
  ) async {
    final game = await pumpGame(tester);
    game.startGame();
    await tester.pump();

    await tester.tapAt(tester.getCenter(find.byType(GameWidget<SmolJumpGame>)));
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

  testWidgets('death shows game over and Play Again restarts immediately', (
    tester,
  ) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    await tester.pump();

    game.lives = 1;
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

  testWidgets('volume defaults to 50 percent', (tester) async {
    final game = await pumpGame(tester);

    expect(game.volume, 0.5);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('settings opens from the menu and back returns to it', (
    tester,
  ) async {
    final game = await pumpGame(tester);

    await tester.tap(find.text('SETTINGS'));
    await tester.pump();

    expect(find.byKey(const Key('volumeSlider')), findsOneWidget);
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('PLAY'), findsNothing);

    await tester.tap(find.text('BACK'));
    await tester.pump();

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byKey(const Key('volumeSlider')), findsNothing);
    expect(game.phase, GamePhase.menu);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('dragging the slider updates and persists the volume', (
    tester,
  ) async {
    final game = await pumpGame(tester);
    game.openSettings();
    await tester.pump();

    await tester.drag(find.byKey(const Key('volumeSlider')), const Offset(100, 0));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );

    expect(game.volume, greaterThan(0.5));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('smol_jump.volume'), game.volume);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('settings opens from pause and back returns to pause', (
    tester,
  ) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    game.pauseGame();
    await tester.pump();

    await tester.tap(find.text('SETTINGS'));
    await tester.pump();

    expect(find.byKey(const Key('volumeSlider')), findsOneWidget);
    expect(find.text('PAUSED'), findsNothing);

    await tester.tap(find.text('BACK'));
    await tester.pump();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.byKey(const Key('volumeSlider')), findsNothing);
    expect(game.phase, GamePhase.paused);

    await tester.pumpWidget(const SizedBox.shrink());
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('main menu from game over resets to an idle dino', (
    tester,
  ) async {
    final game = await pumpGame(tester);
    game.startGame();
    game.beginRun();
    game.lives = 1;
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
