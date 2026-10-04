import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/smol_jump_game.dart';
import '../ui/ui_theme.dart';

/// Distance-based score HUD. Lives on the camera viewport so the camera's zoom
/// does not affect it, and stacks a small "HI" line over a large, outlined
/// current score so it stays legible over both the day and night skies.
class ScoreManager extends PositionComponent
    with HasGameReference<SmolJumpGame> {
  ScoreManager()
      : super(
          anchor: Anchor.topRight,
          priority: 100,
        );

  static const double _pixelsPerScore = 6;
  static const double _rightInset = 12;
  static const double _topInset = 10;

  static final TextPaint _bestPaint = TextPaint(
    style: const TextStyle(
      fontFamily: UiTheme.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 1,
      color: Color(0xFFF2C14E),
      shadows: UiTheme.textOutline,
    ),
  );

  static final TextPaint _scorePaint = TextPaint(
    style: const TextStyle(
      fontFamily: UiTheme.fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      letterSpacing: 1,
      color: Color(0xFFFFFFFF),
      shadows: UiTheme.textOutline,
    ),
  );

  late final TextComponent _best;
  late final TextComponent _score;

  double _distance = 0;
  String _lastBest = '';
  String _lastScore = '';

  @override
  Future<void> onLoad() async {
    _best = TextComponent(
      anchor: Anchor.topRight,
      textRenderer: _bestPaint,
      priority: 1,
    );
    _score = TextComponent(
      anchor: Anchor.topRight,
      textRenderer: _scorePaint,
      priority: 2,
    );
    await add(_best);
    await add(_score);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isRunning && !game.isGameOver) {
      _distance += game.world.speed * dt;
      game.score = (_distance / _pixelsPerScore).floor();
    }

    final parent = this.parent;
    if (parent is Viewport) {
      position = Vector2(parent.size.x - _rightInset, _topInset);
    }

    // Hidden on the menu / start prompt; the menu shows the best score itself.
    final visible = game.phase == GamePhase.playing ||
        game.phase == GamePhase.paused ||
        game.phase == GamePhase.gameOver;
    final showBest = visible && game.highScore > 0;

    final bestText = showBest ? 'HI ${UiTheme.formatScore(game.highScore)}' : '';
    if (bestText != _lastBest) {
      _lastBest = bestText;
      _best.text = bestText;
    }

    _score.position = Vector2(0, showBest ? 22 : 0);
    final scoreText = visible ? UiTheme.formatScore(game.score) : '';
    if (scoreText != _lastScore) {
      _lastScore = scoreText;
      _score.text = scoreText;
    }
  }

  void reset() {
    _distance = 0;
    game.score = 0;
    _lastScore = '';
  }
}
