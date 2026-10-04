import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/audio.dart';
import '../managers/score.dart';
import 'world.dart';

/// The high-level screen the game is currently on.
enum GamePhase { menu, ready, playing, paused, gameOver }

class SmolJumpGame extends FlameGame<SmolJumpWorld> with KeyboardEvents {
  SmolJumpGame() : super(world: SmolJumpWorld());

  static const String overlayMainMenu = 'mainMenu';
  static const String overlayStartPrompt = 'startPrompt';
  static const String overlayPause = 'pause';
  static const String overlayPauseButton = 'pauseButton';
  static const String overlayGameOver = 'gameOver';

  static const String _highScoreKey = 'smol_jump.high_score';

  int score = 0;
  int highScore = 0;

  /// Whether the run that just ended set a new personal best (drives the
  /// "NEW BEST!" banner on the game-over screen).
  bool lastRunNewBest = false;

  GamePhase phase = GamePhase.menu;

  /// Kept as getters so every component guard keeps its original meaning:
  /// paused/menu/ready all read as "not running", and only a death counts as
  /// game over.
  bool get isRunning => phase == GamePhase.playing;
  bool get isGameOver => phase == GamePhase.gameOver;

  late final ScoreManager _scoreManager;
  final AudioManager audio = AudioManager();

  @override
  Color backgroundColor() => const Color(0xFF9AD5E8);

  @override
  Future<void> onLoad() async {
    // Kick off audio pre-loading without blocking the first frame; play calls
    // are no-ops until it completes (and stay silent if it fails).
    unawaited(audio.load());
    await super.onLoad();

    camera.viewfinder
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(
        SmolJumpWorld.virtualWidth / 2,
        SmolJumpWorld.virtualHeight,
      );

    _scoreManager = ScoreManager();
    await camera.viewport.add(_scoreManager);
    await camera.viewport.add(_TapInput(this));

    await _loadHighScore();

    phase = GamePhase.menu;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x > 0) {
      camera.viewfinder.zoom = zoomForWidth(size.x);
    }
  }

  /// Integer zoom so each virtual pixel maps to whole screen pixels.
  static double zoomForWidth(double logicalWidth) {
    final zoom = (logicalWidth / SmolJumpWorld.virtualWidth).floor();
    return zoom < 1 ? 1 : zoom.toDouble();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Key repeat arrives as KeyRepeatEvent, so this already ignores auto-repeat.
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.keyP) {
      if (phase == GamePhase.playing) {
        pauseGame();
        return KeyEventResult.handled;
      }
      if (phase == GamePhase.paused) {
        resumeGame();
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      primaryAction();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// The tap/space action, routed by the current phase.
  void primaryAction() {
    switch (phase) {
      case GamePhase.playing:
        world.dino.jump();
      case GamePhase.ready:
        beginRun();
      case GamePhase.menu:
      case GamePhase.paused:
      case GamePhase.gameOver:
        break;
    }
  }

  /// "Play" from the main menu: show the Tap to Start prompt, world stays idle.
  void startGame() {
    if (phase != GamePhase.menu) {
      return;
    }
    overlays.remove(overlayMainMenu);
    overlays.add(overlayStartPrompt);
    phase = GamePhase.ready;
  }

  /// The first tap of a run: start scrolling and make the dino leap, which is
  /// what the "Tap to Start" instruction promises.
  void beginRun() {
    if (phase != GamePhase.ready) {
      return;
    }
    overlays.remove(overlayStartPrompt);
    overlays.add(overlayPauseButton);
    phase = GamePhase.playing;
    world.dino.startRunning();
    world.dino.jump();
  }

  void pauseGame() {
    if (phase != GamePhase.playing) {
      return;
    }
    phase = GamePhase.paused;
    overlays.remove(overlayPauseButton);
    overlays.add(overlayPause);
    pauseEngine();
  }

  void resumeGame() {
    if (phase != GamePhase.paused) {
      return;
    }
    overlays.remove(overlayPause);
    overlays.add(overlayPauseButton);
    phase = GamePhase.playing;
    resumeEngine();
  }

  /// Restart immediately from pause or game over.
  void restartGame() {
    if (phase != GamePhase.paused && phase != GamePhase.gameOver) {
      return;
    }
    overlays.remove(overlayPause);
    overlays.remove(overlayGameOver);
    _resetRunState(running: true);
    phase = GamePhase.playing;
    overlays.add(overlayPauseButton);
    resumeEngine();
  }

  /// Return to the main menu, discarding the current run.
  void goToMenu() {
    overlays
      ..remove(overlayPause)
      ..remove(overlayGameOver)
      ..remove(overlayPauseButton)
      ..remove(overlayStartPrompt)
      ..add(overlayMainMenu);
    _resetRunState(running: false);
    phase = GamePhase.menu;
    resumeEngine();
  }

  void dinoHit() {
    if (isGameOver) {
      return;
    }
    phase = GamePhase.gameOver;
    world.dino.die();
    audio.playLose();
    lastRunNewBest = score > highScore;
    if (lastRunNewBest) {
      highScore = score;
      _persistHighScore(highScore);
    }
    overlays.remove(overlayPauseButton);
    overlays.add(overlayGameOver);
    pauseEngine();
  }

  /// Clears the world and score so the next screen starts clean. [running]
  /// leaves the dino mid-run (restart) vs. back in its idle menu pose.
  void _resetRunState({required bool running}) {
    score = 0;
    unawaited(audio.stopAll());
    world.reset();
    _scoreManager.reset();
    if (!running) {
      world.dino.resetToIdle();
    }
  }

  @override
  void onRemove() {
    unawaited(audio.dispose());
    super.onRemove();
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt(_highScoreKey) ?? 0;
    } catch (_) {
      highScore = 0;
    }
  }

  Future<void> _persistHighScore(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, value);
    } catch (_) {
      // Persistence is best effort.
    }
  }
}

/// Full viewport touch surface: any tap triggers the primary game action.
class _TapInput extends PositionComponent with TapCallbacks {
  _TapInput(this._game) : super(priority: 1000);

  final SmolJumpGame _game;

  @override
  void onMount() {
    super.onMount();
    final parent = this.parent;
    if (parent is Viewport) {
      size = parent.size.clone();
    }
  }

  @override
  void onParentResize(Vector2 maxSize) {
    super.onParentResize(maxSize);
    size = maxSize.clone();
  }

  @override
  void onTapDown(TapDownEvent event) => _game.primaryAction();
}
