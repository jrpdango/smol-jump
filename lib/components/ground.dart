import 'package:flame/components.dart';

import '../game/world.dart';
import 'scrolling_layer.dart';

/// Seamlessly tiling ground strip.
class Ground extends ScrollingLayer {
  Ground()
      : super(
          asset: 'ground.png',
          position: Vector2(SmolJumpWorld.groundLeft, SmolJumpWorld.groundY),
          size: Vector2(
            SmolJumpWorld.groundWidth,
            SmolJumpWorld.groundHeight,
          ),
        );
}
