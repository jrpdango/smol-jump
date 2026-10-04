import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/erls_dino_game.dart';
import 'ui/overlays.dart';

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
      overlayBuilderMap: buildOverlayBuilderMap(),
      initialActiveOverlays: const [ErlsDinoGame.overlayMainMenu],
    ),
  );
}
