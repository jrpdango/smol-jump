import 'package:flame/components.dart';

enum DinoState { idle, run, jump, duck, dead }

class Dino extends PositionComponent {
  Dino({super.position, super.size});

  DinoState state = DinoState.idle;
}
