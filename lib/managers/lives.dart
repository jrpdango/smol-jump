import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/smol_jump_game.dart';

/// The hearts HUD. Lives on the camera viewport so the camera's zoom does not
/// affect it, and draws one filled or empty heart per life at the top-left,
/// opposite the score.
class LivesManager extends PositionComponent
    with HasGameReference<SmolJumpGame> {
  LivesManager() : super(anchor: Anchor.topLeft, priority: 100);

  static const String fullAsset = 'heart-full.png';
  static const String emptyAsset = 'heart-empty.png';

  /// Drawn at an integer 2x the 14x12 source so the pixels stay crisp while the
  /// hearts read clearly against the sky.
  static const double heartWidth = 28;
  static const double heartHeight = 24;
  static const double heartGap = 6;
  static const double _leftInset = 12;
  static const double _topInset = 10;

  final Paint _paint = Paint()..filterQuality = FilterQuality.none;

  ui.Image? _full;
  ui.Image? _empty;

  @override
  Future<void> onLoad() async {
    _full = await game.images.load(fullAsset);
    _empty = await game.images.load(emptyAsset);
    position = Vector2(_leftInset, _topInset);
  }

  @override
  void render(Canvas canvas) {
    final full = _full;
    final empty = _empty;
    if (full == null || empty == null) {
      return;
    }
    final visible =
        game.phase == GamePhase.playing ||
        game.phase == GamePhase.paused ||
        game.phase == GamePhase.gameOver;
    if (!visible) {
      return;
    }

    final lives = game.lives;
    for (var i = 0; i < SmolJumpGame.maxLives; i++) {
      final image = i < lives ? full : empty;
      final left = i * (heartWidth + heartGap);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(left, 0, heartWidth, heartHeight),
        _paint,
      );
    }
    super.render(canvas);
  }
}
