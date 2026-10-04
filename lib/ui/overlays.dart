import 'package:flutter/widgets.dart';

import '../game/smol_jump_game.dart';
import 'game_over_overlay.dart';
import 'main_menu_overlay.dart';
import 'pause_button_overlay.dart';
import 'pause_overlay.dart';
import 'start_prompt_overlay.dart';

typedef OverlayBuilder = Widget Function(
  BuildContext context,
  SmolJumpGame game,
);

/// Maps every overlay name the game can request to its widget. Shared by
/// `main.dart` and the widget tests so the two never drift apart.
Map<String, OverlayBuilder> buildOverlayBuilderMap() => {
      SmolJumpGame.overlayMainMenu: (context, game) => MainMenuOverlay(
            highScore: game.highScore,
            onPlay: game.startGame,
          ),
      SmolJumpGame.overlayStartPrompt: (context, game) =>
          const StartPromptOverlay(),
      SmolJumpGame.overlayPauseButton: (context, game) => PauseButtonOverlay(
            onPause: game.pauseGame,
          ),
      SmolJumpGame.overlayPause: (context, game) => PauseOverlay(
            onResume: game.resumeGame,
            onRestart: game.restartGame,
            onMenu: game.goToMenu,
          ),
      SmolJumpGame.overlayGameOver: (context, game) => GameOverOverlay(
            score: game.score,
            highScore: game.highScore,
            newBest: game.lastRunNewBest,
            onRestart: game.restartGame,
            onMenu: game.goToMenu,
          ),
    };
