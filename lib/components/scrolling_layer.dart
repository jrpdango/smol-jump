import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../game/erls_dino_game.dart';

/// A horizontally scrolling, seamlessly tiled sprite layer.
///
/// The tile image is authored at base pixel size (1 art px = 1 virtual px) and
/// repeated across the component's width. [applyTint] recolors the layer via a
/// `modulate` color filter, so a day/night cycle can shift its mood without
/// separate art.
class ScrollingLayer extends PositionComponent
    with HasGameReference<ErlsDinoGame> {
  ScrollingLayer({
    required this.asset,
    required Vector2 position,
    required Vector2 size,
    this.speedMultiplier = 1.0,
    super.priority,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  final String asset;
  final double speedMultiplier;

  final Paint paint = Paint()..filterQuality = FilterQuality.none;

  Sprite? _sprite;
  double _offset = 0;

  double get tileWidth => _sprite?.srcSize.x ?? size.x;

  @override
  Future<void> onLoad() async {
    _sprite = Sprite(await game.images.load(asset));
  }

  /// Advance by the ground [speed] scaled by [speedMultiplier], wrapping at the
  /// tile width so the layer repeats seamlessly.
  void scroll(double speed, double dt) {
    final tw = tileWidth;
    if (tw <= 0) {
      return;
    }
    _offset = (_offset + speed * speedMultiplier * dt) % tw;
    if (_offset < 0) {
      _offset += tw;
    }
  }

  void resetScroll() => _offset = 0;

  /// Multiplies the layer's colors by [color] (`Color(0xFFFFFFFF)` = unchanged).
  void applyTint(Color color) {
    paint.colorFilter = ColorFilter.mode(color, BlendMode.modulate);
  }

  @override
  void render(Canvas canvas) {
    final sprite = _sprite;
    if (sprite == null) {
      return;
    }
    final tw = sprite.srcSize.x;
    if (tw <= 0) {
      return;
    }
    for (var x = -_offset; x < size.x; x += tw) {
      sprite.render(
        canvas,
        position: Vector2(x, 0),
        size: Vector2(tw, size.y),
        overridePaint: paint,
      );
    }
  }
}
