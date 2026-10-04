import 'package:flutter/material.dart';

import 'ui_theme.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    this.highScore = 0,
    this.newBest = false,
    required this.onRestart,
    required this.onMenu,
  });

  final int score;
  final int highScore;
  final bool newBest;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: UiTheme.scrim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('GAME OVER', style: UiTheme.heading),
              const SizedBox(height: 24),
              if (newBest) ...[
                const Text('NEW BEST!', style: UiTheme.label),
                const SizedBox(height: 8),
              ],
              Text(
                'SCORE  ${UiTheme.formatScore(score)}',
                style: UiTheme.label,
              ),
              const SizedBox(height: 6),
              Text(
                'BEST   ${UiTheme.formatScore(highScore)}',
                style: UiTheme.body,
              ),
              const SizedBox(height: 32),
              PixelButton(
                label: 'PLAY AGAIN',
                accent: true,
                onPressed: onRestart,
              ),
              const SizedBox(height: 14),
              PixelButton(label: 'MAIN MENU', onPressed: onMenu),
            ],
          ),
        ),
      ),
    );
  }
}
