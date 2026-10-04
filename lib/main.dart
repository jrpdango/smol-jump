import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/smol_jump_game.dart';
import 'ui/overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final game = SmolJumpGame();
  runApp(
    GameWidget<SmolJumpGame>(
      game: game,
      overlayBuilderMap: buildOverlayBuilderMap(),
      initialActiveOverlays: const [SmolJumpGame.overlayMainMenu],
    ),
  );
}
