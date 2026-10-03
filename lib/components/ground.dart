import 'package:flame/components.dart';

import '../game/world.dart';
import 'scrolling_layer.dart';

/// Seamlessly tiling ground strip.
class Ground extends ScrollingLayer {
  Ground()
      : super(
          asset: 'ground.png',
          position: Vector2(ErlsDinoWorld.groundLeft, ErlsDinoWorld.groundY),
          size: Vector2(
            ErlsDinoWorld.groundWidth,
            ErlsDinoWorld.groundHeight,
          ),
        );
}
