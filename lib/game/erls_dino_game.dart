import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/score.dart';
import 'world.dart';

class ErlsDinoGame extends FlameGame<ErlsDinoWorld> with KeyboardEvents {
  ErlsDinoGame() : super(world: ErlsDinoWorld());

  static const String overlayGameOver = 'gameOver';
  static const String _highScoreKey = 'erls_dino.high_score';

  int score = 0;
  int highScore = 0;
  bool isRunning = false;
  bool isGameOver = false;

  late final ScoreManager _scoreManager;

  @override
  Color backgroundColor() => const Color(0xFF9AD5E8);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(
        ErlsDinoWorld.virtualWidth / 2,
        ErlsDinoWorld.virtualHeight,
      );

    _scoreManager = ScoreManager();
    await camera.viewport.add(_scoreManager);
    await camera.viewport.add(_TapInput(this));

    await _loadHighScore();
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
    final zoom = (logicalWidth / ErlsDinoWorld.virtualWidth).floor();
    return zoom < 1 ? 1 : zoom.toDouble();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _primaryAction();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _primaryAction() {
    if (isGameOver) {
      reset();
      return;
    }
    if (!isRunning) {
      isRunning = true;
      world.dino.startRunning();
    }
    world.dino.jump();
  }

  void dinoHit() {
    if (isGameOver) {
      return;
    }
    isGameOver = true;
    isRunning = false;
    world.dino.die();
    if (score > highScore) {
      highScore = score;
      _persistHighScore(highScore);
    }
    overlays.add(overlayGameOver);
    pauseEngine();
  }

  void reset() {
    overlays.remove(overlayGameOver);
    score = 0;
    isGameOver = false;
    isRunning = true;
    world.reset();
    _scoreManager.reset();
    resumeEngine();
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

  final ErlsDinoGame _game;

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
  void onTapDown(TapDownEvent event) => _game._primaryAction();
}
