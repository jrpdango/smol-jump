import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/erls_dino_game.dart';
import 'ui/game_over_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final game = ErlsDinoGame();
  runApp(
    GameWidget<ErlsDinoGame>(
      game: game,
      overlayBuilderMap: {
        ErlsDinoGame.overlayGameOver: (context, game) => GameOverOverlay(
              score: game.score,
              highScore: game.highScore,
              onRestart: game.reset,
            ),
      },
    ),
  );
}
