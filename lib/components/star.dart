import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';

/// A star that fades in at night and twinkles.
///
/// [setNight] carries the cycle's night intensity; the per-star [phase] offsets
/// the twinkle so the field doesn't pulse in unison.
class Star extends SpriteComponent with HasGameReference<ErlsDinoGame> {
  Star({
    required this.asset,
    required super.position,
    required Vector2 size,
    required this.phase,
    super.priority,
  }) : super(size: size, anchor: Anchor.center);

  final String asset;
  final double phase;

  double _time = 0;
  double _night = 0;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await game.images.load(asset));
    paint.filterQuality = FilterQuality.none;
    _apply();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_night > 0) {
      _apply();
    }
  }

  void setNight(double value) {
    _night = value.clamp(0.0, 1.0);
    _apply();
  }

  void _apply() {
    final twinkle = 0.55 + 0.45 * sin(_time * 2.2 + phase);
    final a = (_night * twinkle).clamp(0.0, 1.0);
    paint.colorFilter = ColorFilter.mode(
      Color.fromRGBO(255, 255, 255, a),
      BlendMode.modulate,
    );
  }
}
