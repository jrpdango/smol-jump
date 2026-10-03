import 'package:flame/components.dart';

enum CactusSize { small, large }

class Cactus extends PositionComponent {
  Cactus({
    this.cactusSize = CactusSize.small,
    super.position,
    super.size,
  });

  final CactusSize cactusSize;
}
