import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';

/// Distance based score HUD, lives on the camera viewport so the camera's
/// zoom does not affect it.
class ScoreManager extends TextComponent with HasGameReference<ErlsDinoGame> {
  ScoreManager()
      : super(
          anchor: Anchor.topRight,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xFF1E1E2E),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          priority: 100,
        );

  static const double _pixelsPerScore = 6;

  double _distance = 0;
  String _lastText = '';

  @override
  void update(double dt) {
    super.update(dt);

    if (game.isRunning && !game.isGameOver) {
      _distance += game.world.speed * dt;
      game.score = (_distance / _pixelsPerScore).floor();
    }

    final parent = this.parent;
    if (parent is Viewport) {
      position = Vector2(parent.size.x - 8, 10);
    }

    final text = 'HI ${_format(game.highScore)}  ${_format(game.score)}';
    if (text != _lastText) {
      _lastText = text;
      this.text = text;
    }
  }

  void reset() {
    _distance = 0;
    game.score = 0;
    _lastText = '';
  }

  static String _format(int value) => value.toString().padLeft(5, '0');
}
