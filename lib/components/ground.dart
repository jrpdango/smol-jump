import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

import '../game/world.dart';

/// Seamlessly tiling ground strip driven by a parallax layer.
class Ground extends ParallaxComponent {
  Ground()
      : super(
          position: Vector2(ErlsDinoWorld.groundLeft, ErlsDinoWorld.groundY),
          size: Vector2(
            ErlsDinoWorld.groundWidth,
            ErlsDinoWorld.groundHeight,
          ),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('ground.png');
    parallax = Parallax(
      [
        ParallaxLayer(
          ParallaxImage(
            image,
            repeat: ImageRepeat.repeatX,
            alignment: Alignment.topLeft,
            fill: LayerFill.none,
            filterQuality: FilterQuality.none,
          ),
        ),
      ],
      baseVelocity: Vector2.zero(),
      size: size,
    );
  }

  void setScrollSpeed(double speed) {
    parallax?.baseVelocity = Vector2(speed, 0);
  }
}
