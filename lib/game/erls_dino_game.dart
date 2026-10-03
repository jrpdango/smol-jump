import 'package:flame/game.dart';

import 'world.dart';

class ErlsDinoGame extends FlameGame<ErlsDinoWorld> {
  ErlsDinoGame() : super(world: ErlsDinoWorld());

  int score = 0;
  int highScore = 0;
}
