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

/// Wraps a menu action so pressing its button plays the selection blip first.
VoidCallback _withSelect(SmolJumpGame game, VoidCallback action) =>
    () {
      game.audio.playSelect();
      action();
    };

/// Maps every overlay name the game can request to its widget. Shared by
/// `main.dart` and the widget tests so the two never drift apart.
Map<String, OverlayBuilder> buildOverlayBuilderMap() => {
      SmolJumpGame.overlayMainMenu: (context, game) => MainMenuOverlay(
            highScore: game.highScore,
            onPlay: _withSelect(game, game.startGame),
          ),
      SmolJumpGame.overlayStartPrompt: (context, game) =>
          const StartPromptOverlay(),
      SmolJumpGame.overlayPauseButton: (context, game) => PauseButtonOverlay(
            onPause: game.pauseGame,
          ),
      SmolJumpGame.overlayPause: (context, game) => PauseOverlay(
            onResume: _withSelect(game, game.resumeGame),
            onRestart: _withSelect(game, game.restartGame),
            onMenu: _withSelect(game, game.goToMenu),
          ),
      SmolJumpGame.overlayGameOver: (context, game) => GameOverOverlay(
            score: game.score,
            highScore: game.highScore,
            newBest: game.lastRunNewBest,
            onRestart: _withSelect(game, game.restartGame),
            onMenu: _withSelect(game, game.goToMenu),
          ),
    };
