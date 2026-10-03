import 'package:flame/components.dart';

class ObstacleSpawner extends Component {
  double scrollSpeed = 0;
  double elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;
  }
}
